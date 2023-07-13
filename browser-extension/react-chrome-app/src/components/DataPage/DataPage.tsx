import React, { useState } from 'react';
import "./DataPage.css"

interface ButtonProps {
  label: string;
}

const ToggleButton: React.FC<ButtonProps> = ({ label }) => {
  const [isOn, setIsOn] = useState(false);

  const toggleButton = () => {
    setIsOn(!isOn);
  };

  return (
    <div className={`toggle-button ${isOn ? 'on' : 'off'}`} onClick={toggleButton}>
      <div className="slider">
        <div className={`slider-ball ${isOn ? 'on' : 'off'}`} />
      </div>
      <span className="label">{label}</span>
    </div>
  );
};

const DataPage: React.FC = () => {
  return (
    <div>
      <ToggleButton label="Button 1" />
      <ToggleButton label="Button 2" />
      <ToggleButton label="Button 3" />
      <ToggleButton label="Button 4" />
    </div>
  );
};

export default DataPage;