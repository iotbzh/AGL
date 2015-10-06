# This script intended to be sourced by another one.

# syntax:
#  unzip_proprietaries
function unzip_proprietaries
{
	[ -d binary-tmp ] && return 0
	echo -e "\n"
	echo -e "Please download these 2 files from \"http://www.renesas.com/secret/r_car_download/rcar_demoboard.jsp\" and copy them into your \"$HOME\" directory:"
	echo -e "* R-Car_Series_Evaluation_Software_Package_for_Linux-20150727.zip"
	echo -e "* R-Car_Series_Evaluation_Software_Package_of_Linux_Drivers-20150727.zip"
	echo -e "and press [ENTER] to continue...\n"
	read
	[ -f "$HOME/R-Car_Series_Evaluation_Software_Package_for_Linux-20150727.zip" ] && \
	[ -f "$HOME/R-Car_Series_Evaluation_Software_Package_of_Linux_Drivers-20150727.zip" ] && \
	mkdir binary-tmp && \
	unzip -o "$HOME/R-Car_Series_Evaluation_Software_Package_for_Linux-20150727.zip" -d binary-tmp && \
		unzip -o "$HOME/R-Car_Series_Evaluation_Software_Package_of_Linux_Drivers-20150727.zip" -d binary-tmp
}

# syntax:
#  copy_mum_zip <board-name> (ex: porter, silk)
function copy_mum_zip
{
	board=$1

	if [ ! -f meta-renesas/meta-rcar-gen2/copy_gfx_software_$board.sh ]; then
		echo "Multimedia installer for board name \"$board\" not found"
		return 1
	fi

	if ! unzip_proprietaries; then
		echo "Multimedia proprietaries files not found"
		return 1
	fi

	cd meta-renesas/meta-rcar-gen2
	if [ ! -f .last-board-set ] || [ $(cat .last-board-set) != $board ]; then
		./copy_gfx_software_$board.sh ../../binary-tmp && \
		./copy_mm_software_lcb.sh ../../binary-tmp && \
		echo -n $board > .last-board-set
	fi
	cd -
}

