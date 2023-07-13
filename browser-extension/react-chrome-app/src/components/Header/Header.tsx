import React from "react";
import "./Header.css"
import Nav from 'react-bootstrap/Nav';

interface HeaderProps {
    changePage: (p: string) => void;
  }

const Header: React.FC<HeaderProps> = ({changePage}) => {
    return (
    <Nav>
          <Nav.Link onClick={() => changePage('user')}>Profile</Nav.Link>
          <Nav.Link onClick={() => changePage('data')}>Data Settings</Nav.Link>
          <Nav.Link onClick={() => changePage('wallet')}>Wallet</Nav.Link>
    </Nav>
    )
}

export default Header;
