import "../styles/globals.css";
import Link from "next/link";

function MyApp({ Component, pageProps }) {
  return (
    <div>
      <nav className="border-b p-6">
        <p className="text-4xl font-bold">Moment Marketplace</p>
        <p> 당신의 순간을 거래 하세요 📷</p>
        <div className="flex mt-4 justify-end">
          <div style={{ border: 1, borderColor: "black", borderStyle: "solid", borderRadius: 5 }}>
            <Link href="/">
              <a className="mr-4 text-amber-600" style={{ padding: 20 }}>
                Home
              </a>
            </Link>
            <Link href="/create-nft">
              <a className="mr-6 text-amber-600" style={{ padding: 20 }}>
                Sell NFT
              </a>
            </Link>
            <Link href="/my-nfts">
              <a className="mr-6 text-amber-600" style={{ padding: 20 }}>
                My NFTs
              </a>
            </Link>
            <Link href="/dashboard">
              <a className="mr-6 text-amber-600" style={{ padding: 20 }}>
                Dashboard
              </a>
            </Link>
          </div>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  );
}

export default MyApp;
