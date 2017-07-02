# Download H36M images
mkdir pose-hg-demo/images
cd pose-hg-demo/images
wget http://visiondata.cis.upenn.edu/volumetric/h36m/Sample.tar
tar -xf Sample.tar
rm Sample.tar

# Download H36M annotations
cd ..
wget http://visiondata.cis.upenn.edu/harvesting/h36m/h36m_annot.tar
tar -xf h36m_annot.tar
rm h36m_annot.tar
 
# Download Stacked Hourglass model
wget http://www-personal.umich.edu/~alnewell/pose/umich-stacked-hourglass.zip
unzip umich-stacked-hourglass.zip
mv umich-stacked-hourglass/umich-stacked-hourglass.t7 ./
rm umich-stacked-hourglass.zip
rm -r umich-stacked-hourglass
cd ../