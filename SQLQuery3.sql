--cleaning data in SQL Queries

SELECT *
FROM PortfolioProject..Nashvillehousing


--standardize date format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject..Nashvillehousing


--SELECT SaleDate, CAST(SaleDate as date)
--FROM PortfolioProject..Nashvillehousing

UPDATE Nashvillehousing
SET SaleDate =  CONVERT(DATE,SaleDate)

ALTER TABLE Nashvillehousing
ADD SaleDateConverted Date;


UPDATE Nashvillehousing
SET SaleDateConverted =  CONVERT(DATE,SaleDate)


--populate property address data



SELECT *
FROM PortfolioProject..Nashvillehousing
--WHERE PropertyAddress is null
ORDER BY ParcelID




SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject..Nashvillehousing a
join  PortfolioProject..Nashvillehousing b
on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashvillehousing a
join  PortfolioProject..Nashvillehousing b
on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



--Breaking out Address into individual columns(Address, city, state)

SELECT PropertyAddress
FROM PortfolioProject..Nashvillehousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..Nashvillehousing
--WHERE PropertyAddress is null




ALTER TABLE Nashvillehousing
ADD PropertySplitAddress Nvarchar(255);


UPDATE Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)




ALTER TABLE Nashvillehousing
ADD PropertySplitCity Nvarchar(255);


UPDATE Nashvillehousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..Nashvillehousing



SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..Nashvillehousing




ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress Nvarchar(255);


UPDATE Nashvillehousing
SET OwnerSplitAddress =  PARSENAME (REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Nashvillehousing
ADD OwnerSplitCity Nvarchar(255);


UPDATE Nashvillehousing
SET OwnerSplitCity =  PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Nashvillehousing
ADD OwnerSplitState Nvarchar(255);


UPDATE Nashvillehousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)



SELECT *
FROM PortfolioProject..Nashvillehousing


--change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
FROM PortfolioProject..Nashvillehousing


UPDATE Nashvillehousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END


--Remove duplicates
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
		     PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
				)row_num



FROM PortfolioProject..Nashvillehousing

)

SELECT *
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress



--Delete unused columns

SELECT *
FROM PortfolioProject..Nashvillehousing

ALTER TABLE PortfolioProject..Nashvillehousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject..Nashvillehousing
DROP COLUMN SaleDate


