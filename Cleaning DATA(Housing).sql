--the project cleaing data in sql Queries

select *
from ProtfolioProject.dbo.NashvilleHousing
----

--Standardize Data Format 
Select SaleDate
from ProtfolioProject.dbo.NashvilleHousing

update NashvilleHousing 
set SaleDate=CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted=CONVERT(Date,SaleDate)

Select SaleDateConverted 
from ProtfolioProject.dbo.NashvilleHousing

-----
--Populate Property Address data
select *
from ProtfolioProject.dbo.NashvilleHousing
 where PropertyAddress is null 
 order by ParcelID


select a.ParcelID,a.PropertyAddress ,b.ParcelID ,b.PropertyAddress
from ProtfolioProject.dbo.NashvilleHousing as a 
join ProtfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

update a 
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from ProtfolioProject.dbo.NashvilleHousing as a 
join ProtfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

Select *
From ProtfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

-------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From ProtfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From ProtfolioProject..NashvilleHousing


--ADD table 
Alter table NashvilleHousing
Add Property_Address Nvarchar(255);

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From ProtfolioProject.dbo.NashvilleHousing

--work on OwnerAddress
Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From ProtfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitstate Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


update NashvilleHousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

update NashvilleHousing
set OwnerSplitstate =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From ProtfolioProject.dbo.NashvilleHousing

---------------------------------

--Change Y and N to Yes and No "SoldAsVacant" field 

select Distinct(SoldAsVacant), count (SoldAsVacant)
From ProtfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant='Y' THEN 'YES'
When SoldAsVacant='N' THEN 'NO'
Else SoldAsVacant
END
from ProtfolioProject..NashvilleHousing

Update NashvilleHousing
set SoldAsVacant= Case When SoldAsVacant='Y' THEN 'YES'
When SoldAsVacant='N' THEN 'NO'
Else SoldAsVacant
END

----------------------------------------
--Remove Duplicates
--CTE

WITH RowNumCTE As(
select *,
ROW_NUMBER() Over (
PARTITION BY ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by 
				 UniqueID
) row_num
From ProtfolioProject.dbo.NashvilleHousing 

)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


ALTER TABLE ProtfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From ProtfolioProject..NashvilleHousing