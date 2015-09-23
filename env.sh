# This script intended to be sourced by another one.

# syntax:
#  git_add_remote_upstream <sub-directory> <git_repo_url>
function git_add_remote_upstream
{
	directory=$1
	repo=$2

	[ -d $directory ] && {
		cd $directory
		git remote -v | grep upstream > /dev/null ||
			git remote add upstream $repo
		cd - > /dev/null
	}
}

# syntax:
#  copy_mum_zip <board-name> (ex: porter, silk)
function copy_mum_zip
{
	board=$1

	[ ! -d binary-tmp ] &&
	{
		echo -e "\n"
		echo -e "Please download these 2 files from \"http://www.renesas.com/secret/r_car_download/rcar_demoboard.jsp\" and copy them into your \"$HOME\" directory:"
		echo -e "* R-Car_Series_Evaluation_Software_Package_for_Linux-20150727.zip"
		echo -e "* R-Car_Series_Evaluation_Software_Package_of_Linux_Drivers-20150727.zip"
		echo -e "and press [ENTER] to continue...\n"
		read
		mkdir binary-tmp
		cd binary-tmp
		unzip -o "$HOME/R-Car_Series_Evaluation_Software_Package_for_Linux-20150727.zip"
		unzip -o "$HOME/R-Car_Series_Evaluation_Software_Package_of_Linux_Drivers-20150727.zip"
		cd -
	}

	if [ -f meta-renesas/meta-rcar-gen2/copy_gfx_software_$board.sh ]; then
		cd meta-renesas/meta-rcar-gen2
		./copy_gfx_software_$board.sh ../../binary-tmp
		./copy_mm_software_lcb.sh ../../binary-tmp
		cd -
	else
		echo "Board name \"$board\" not found"
		exit 1
	fi
}

