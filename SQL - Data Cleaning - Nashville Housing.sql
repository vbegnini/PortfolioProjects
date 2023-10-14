-- CLEANING DATA IN SQL QUERIES

SELECT *
FROM [dbo].[NashvilleHousing]

-- 1. Stardandize Date Format:
-- changing the date format using CONVERT() and then updating it;

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
SET SaleDate = CONVERT(Date, SaleDate)

-- 2. Populate property address data:

SELECT *
FROM [dbo].[NashvilleHousing]
WHERE PropertyAddress is null
ORDER BY ParcelID

-- after finding out we do have PropertyAddresses as "NULL" - but there ParcelIDs that are the same, we could populate the missing PropertyAddresses missing with the address related to the ParcelID in common:
-- needed to create a SELF JOIN for the purpose and ISNULL() - and the updated it:

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- 3. Breaking out address into individuals columns (Address, City, State) - because they were altogether having a comma as a "delimiter" (CHARINDEX() for that):
-- needed to use SUBSTRING(), for separating strings;
-- altered table to include the new info, updating it;

SELECT PropertyAddress
FROM [dbo].[NashvilleHousing]

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitCity Nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--*to modify OwnerAddress we're going to use PARSENAME() - for a change, which oddly modify things backwards (that's why "3, 2, 1"):

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitState Nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- 4. Change Y and N to YES and NO in "Sold as Vacant" field;
-- CASE STATEMENT was used to replace the spelling - and then updated it;

SELECT
DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM [dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

SELECT
DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

-- 5. Remove duplicates (creating a CTE with ROW_NUMBER()):

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM [dbo].[NashvilleHousing]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--*now deleting the duplicates:
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM [dbo].[NashvilleHousing]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- 6. Delete unused columns - with ALTER TABLE and DROP COLUMN:

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN SaleDate

SELECT *
FROM [dbo].[NashvilleHousing]


