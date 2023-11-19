SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio Project].[dbo].[NashvilleHousing]


--cleaning data in sql queries

select *
from [Portfolio Project].dbo.NashVilleHousing
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--standardize the Date format

select saledate, convert(date,saledate)
from [Portfolio Project].dbo.NashVilleHousing

update NashVilleHousing
set saledate= CONVERT(Date, saledate)

alter table NashVilleHousing
add saledateconverted date;

update NashVilleHousing
set saledate= CONVERT(Date, saledate)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--populated property address data

select*
from [Portfolio Project].dbo.NashVilleHousing
--where propertyaddress is null
order by parcelid

select a.parcelID,a.propertyaddress,b.parcelid,b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress) 
from [Portfolio Project].dbo.NashVilleHousing a
join [Portfolio Project].dbo.NashVilleHousing b
 on a.parcelid=b.parcelid
 and a.[uniqueId] <> b.[uniqueId]
 where a.propertyaddress is null

 update a
 set propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
 from [Portfolio Project].dbo.NashVilleHousing a
join [Portfolio Project].dbo.NashVilleHousing b
 on a.parcelid=b.parcelid
 and a.[uniqueId] <> b.[uniqueId]
 where a.propertyaddress is null

 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --breakiung out address into individual columns(address, city, state)

 select propertyaddress
 from [Portfolio Project].dbo.NashVilleHousing 
 --where property address is null
 --order by parcelid

 select
 SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1) as address
 ,SUBSTRING(propertyaddress,CHARINDEX (',', propertyaddress) +1,LEN(propertyaddress)) as address

  from [Portfolio Project].dbo.NashVilleHousing

  alter table NashVilleHousing
  add propertysplitaddress nvarchar(255);

  update NashVilleHousing
set propertysplitaddress= SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1)

alter table NashVilleHousing
add propertysplitcity nvarchar(255);


update NashVilleHousing
set propertysplitcity =  SUBSTRING(propertyaddress,CHARINDEX (',', propertyaddress) +1,LEN(propertyaddress))

select *
from [Portfolio Project].dbo.NashVilleHousing



-----------------------------------------------------------------------------------------------------------------------------------------------------------
--alternative method to break up city, address and state using parsename

select owneraddress
from [Portfolio Project].dbo.NashVilleHousing

select 
parsename(replace (owneraddress,',','.'),3)
,parsename(replace (owneraddress,',','.'),2)
,parsename(replace (owneraddress,',','.'),1)
from [Portfolio Project].dbo.NashVilleHousing


 alter table NashVilleHousing
  add ownersplitaddress nvarchar(255);

  update NashVilleHousing
set ownersplitaddress= parsename(replace (owneraddress,',','.'),3)



alter table NashVilleHousing
add ownersplitstate nvarchar(255);


update NashVilleHousing
set ownersplitstate = parsename(replace (owneraddress,',','.'),1)



select *
from [Portfolio Project].dbo.NashVilleHousing
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 
--change Y and N to Yes and No in "sold as vacant" field using a case statement


select distinct(soldasvacant),count(soldasvacant)
from  [Portfolio Project].dbo.NashVilleHousing
group by soldasvacant
order by 2


select soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
   when soldasvacant = 'N' then 'No'
   else soldasvacant
   end

from  [Portfolio Project].dbo.NashVilleHousing


update NashVilleHousing

set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
   when soldasvacant = 'N' then 'No'
   else soldasvacant
   end




WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [Portfolio Project].dbo.NashVilleHousing
)

--DELETE FROM RowNumCTE WHERE row_num > 1;

select * 
from RowNumCTE
WHERE row_num > 1
Order  by PropertyAddress
--Duplicates removed
--------------------------------------------------------------------------------------------------------------------------------
--Now, we delete some columns that are unused
select *
 FROM [Portfolio Project].dbo.NashVilleHousing


 ALTER TABLE [Portfolio Project].dbo.NashVilleHousing
 DROP COLUMN Owneraddress, TaxDistrict,PropertyAddress


 
 ALTER TABLE [Portfolio Project].dbo.NashVilleHousing
 DROP COLUMN saledate

 ------------------------------------------------------------------------------------------------------------------------------------

