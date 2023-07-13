
interface UserPageProps {
    name: string;
    age: number;
    email: string;
  }
  
  const UserPage: React.FC<UserPageProps> = ({ name, age, email }) => {
    return (
      <div>
        <h2>User Profile</h2>
        <p>Name: {name}</p>
        <p>Age: {age}</p>
        <p>Email: {email}</p>
      </div>
    );
  };
  
  export default UserPage;