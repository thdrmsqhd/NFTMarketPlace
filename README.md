# Moment Market Place

- 촬영된 사진, 이미지를 거래 할 수 있는 플랫폼

.env 설정필요

IPFS: https://infura.io/

NEXT_PUBLIC_PROJECT_ID:
NEXT_PUBLIC_PROJECT_SECRET:

```
contracts - NFT 스마트 컨트랙트 코드
.
└── NFTMarketplace.sol

pages - Next Pages
├── \_app.js // Link
├── api
│ └── hello.js
├── create-nft.js // NFT생성
├── dashboard.js // Dashboard
├── index.js // Home
├── my-nfts.js // 내가 소유한 NFT
└── resell-nft.js // NFT 재판매 설정

scripts - 스마트 컨트랙트 배포 코드
└── deploy.js

test - 스마트 컨트랙트 테스트 코드
└── sample-test.js
```

```
npm install
npx hardhat test // 스마트 컨트랙트 테스트
npx hardhat node // localhost로 이더리움 테스트넷 구동
npx hardhat deploy script/deploy.js --network // 테스트넷에 스마트컨트랙트 배포
npm run dev // Next 구동
```

http://localhost:3000
