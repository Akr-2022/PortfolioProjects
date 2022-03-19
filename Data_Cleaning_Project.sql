--This project illustrates data cleaning

Select * from PortfolioProject.dbo.NashVilleHousing

--Standardizing the date format (dat consists of time,removing the time from the dates column

Select SaleDate, convert(date,SaleDate) from PortfolioProject.dbo.NashVilleHousing

Alter table NashVilleHousing
add ConvertedSaleDate date;

Update NashVilleHousing
set ConvertedSaleDate=convert(date,SaleDate)

Select * from PortfolioProject.dbo.NashVilleHousing

ALTER TABLE NashVilleHousing DROP COLUMN SaleDate;

--Populate the PropertyAddress column in the table

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashVilleHousing a
join PortfolioProject.dbo.NashVilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashVilleHousing a
join PortfolioProject.dbo.NashVilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Remove the duplicates

with row_numcte as
(
Select *,
ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SalePrice,ConvertedSaleDate,LegalReference 
order by UniqueID) row_num
from PortfolioProject.dbo.NashVilleHousing 
)

select * from row_numcte where row_num>1

--Separate the Address into individual columns

select PropertyAddress,
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as address
from PortfolioProject.dbo.NashVilleHousing 

Alter table NashVilleHousing
add PropertySplitAddress nvarchar(255);

Update NashVilleHousing 
set PropertySplitAddress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

Alter table NashVilleHousing
add PropertySplitCity nvarchar(255);

Update NashVilleHousing 
set PropertySplitCity=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

Select * from PortfolioProject.dbo.NashVilleHousing 

--Separating the Owner's address

Select OwnerAddress,
parsename(replace(OwnerAddress,',','.'),3), 
parsename(replace(OwnerAddress,',','.'),2), 
parsename(replace(OwnerAddress,',','.'),1) 
from PortfolioProject.dbo.NashVilleHousing 

Alter table PortfolioProject.dbo.NashVilleHousing
add OwnerSplitAddress nvarchar(255);

Update  PortfolioProject.dbo.NashVilleHousing 
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3)

Alter table PortfolioProject.dbo.NashVilleHousing
add OwnerSplitCity nvarchar(255);

Update  PortfolioProject.dbo.NashVilleHousing 
set OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2)

Alter table PortfolioProject.dbo.NashVilleHousing
add OwnerSplitState nvarchar(255);

Update  PortfolioProject.dbo.NashVilleHousing 
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)

Select * from PortfolioProject.dbo.NashVilleHousing

--Changing Y and N to 'Yes' and 'No' in SoldAsVacant Column in Table

Select distinct(SoldAsVacant),count(SoldAsVacant) from PortfolioProject.dbo.NashVilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
case when SoldASVacant='Y' then 'Yes'
	 when SoldASVacant='N' then 'No'
	 else SoldAsVacant
end
from PortfolioProject.dbo.NashVilleHousing

Update  PortfolioProject.dbo.NashVilleHousing 
set SoldAsVacant=case when SoldASVacant='Y' then 'Yes'
	 when SoldASVacant='N' then 'No'
	 else SoldAsVacant
end


Select * from PortfolioProject.dbo.NashVilleHousing

alter table PortfolioProject.dbo.NashVilleHousing
drop column PropertyAddress,OwnerAddress