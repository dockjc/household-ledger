# Supabase

가계부 앱이 쓰는 데이터베이스 스키마입니다.

## 구성

| 테이블 | 용도 |
|---|---|
| `transactions` | 거래 내역 한 건씩 (날짜, 수입/지출, 결제수단, 분류, 메모, 금액, 고정지출 여부) |
| `settings` | 예산·결제수단 설정. `id = 1` 단일 행만 존재합니다. |

두 테이블 모두 `supabase_realtime` 발행에 포함돼 있어서, 한 기기에서 입력하면
같은 주소를 열어둔 다른 기기에 바로 반영됩니다.

## 새 프로젝트에 적용하기

Supabase CLI를 쓰는 경우:

```
supabase link --project-ref <새-project-ref>
supabase db push
```

CLI 없이 하려면 `migrations/` 안의 `.sql` 파일 내용을 Supabase 대시보드의
SQL Editor에 그대로 붙여넣어 실행하면 됩니다.

적용한 뒤에는 앱이 새 프로젝트를 보도록 `index.html` 맨 위의 두 상수를 바꿔주세요.

```js
const SUPABASE_URL = 'https://<project-ref>.supabase.co';
const SUPABASE_KEY = 'sb_publishable_...';
```

`SUPABASE_KEY`는 publishable 키로, 브라우저에 공개되는 값입니다. 실제 접근 권한은
키가 아니라 RLS 정책이 결정합니다.

## 보안 상태

현재 정책은 **로그인 없이 익명으로 읽고 쓰는** 구성입니다. 앱이 GitHub Pages 공개
주소에 배포돼 있으므로, 주소를 아는 사람은 누구나 내역을 보고 고치고 지울 수 있습니다.

실제 금융 데이터를 넣기 시작한다면 Supabase Auth(이메일 로그인 등)를 붙이고,
`transactions`/`settings`에 `user_id uuid references auth.users` 열을 추가한 뒤
정책을 `auth.uid() = user_id` 기준으로 바꿔야 합니다.

## 데이터 백업

스키마만 여기에 있고 **내역 데이터는 포함돼 있지 않습니다.** 앱의 "내보내기" 버튼으로
받는 JSON에 내역과 설정이 함께 담기며, 같은 앱의 "가져오기"로 되돌릴 수 있습니다.
백업 파일은 실제 금융 정보가 들어 있어 `.gitignore`에서 제외하고 있습니다.
