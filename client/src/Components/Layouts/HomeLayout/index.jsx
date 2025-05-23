import Sidebar from "../../Sidebar";
import { Outlet } from "react-router";
import { Stack } from "@mui/material";

import "./index.css";

const HomeLayout = () => {
	return (
		<Stack
			className="home-layout"
			flexDirection="row"
			gap={14}
		>
			<Sidebar />
			<Stack className="home-content-wrapper">
				<Outlet />
			</Stack>
		</Stack>
	);
};

export default HomeLayout;
