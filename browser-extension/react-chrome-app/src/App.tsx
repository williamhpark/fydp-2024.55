import Header from "./components/Header/Header";
import UserPage from "./components/UserPage/UserPage"
import DataPage from "./components/DataPage/DataPage";
import { useState } from "react";
import "./App.css"
import WalletPage from "./components/WalletPage/WalletPage";

const  App = () => {
  const [page, setPage] = useState('user');
  console.log(page)

  const changePage = (p: string) => {
    setPage(p)
  }

  // remove later and useEffect
  const user = {
    name: "John Doe",
    age: 25,
    email: "johndoe@example.com"
  };

  return (
    <div className="browserContainer">
      <div className="row">
        {page === 'user' && <UserPage name={user.name} age={user.age} email={user.email}/>}
        {page === 'data' && <DataPage />}
        {page === 'wallet' && <WalletPage balance={100}/>}
      </div>
      <Header changePage={changePage}/>
    </div>
  );
}

export default App;