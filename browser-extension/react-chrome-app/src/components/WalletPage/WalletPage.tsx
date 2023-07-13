import React from 'react';

interface WalletPageProps {
  balance: number;
}

const WalletPage: React.FC<WalletPageProps> = ({ balance }) => {
  return (
    <div>
      <h2>Wallet Page</h2>
      <p>Balance: {balance}</p>
    </div>
  );
};

export default WalletPage;