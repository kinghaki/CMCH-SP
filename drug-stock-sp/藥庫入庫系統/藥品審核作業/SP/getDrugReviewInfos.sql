USE [HealthResource]
GO

--- 程序名稱：getDrugReviewInfos
--- 程序說明：取得藥品審核明細
--- 編訂人員：蔡易志
--- 校閱人員：孫培然
--- 修訂日期：2021/07/07
CREATE PROCEDURE [dbo].[getDrugReviewInfos](@params NVARCHAR(MAX))
AS BEGIN
   DECLARE @checkNo  INT      = JSON_VALUE(@params,'$.checkNo');
   DECLARE @stockNo  CHAR(04) = JSON_VALUE(@params,'$.stockNo');
   DECLARE @medCode  CHAR(08) = JSON_VALUE(@params,'$.medCode');
   DECLARE @itemType TINYINT  = 10;

   SELECT a.CheckNo    AS [checkNo],
          b.MedCode    AS [medCode],
          b.DrugCode   AS [drugCode],
          b.BrandName1 AS [brandName1],
          c.TotalQty   AS [totalQty],
          c.KeepType   AS [keepType],
          d.LotNo      AS [lotNo],
          d.ExpDate    AS [expDate],
          e.LicenseNo  AS [licenseNo],
          f.IsCoA      AS [isCoA],
          f.IsEffect   AS [isEffect],
          f.IsExterior AS [isExterior],
          f.IsLicense  AS [isLicense],
          f.IsLotNo    AS [isLotNo],
          f.Remark     AS [remark]
     FROM [dbo].[DrugChecking]    AS a,
          [dbo].[DrugBasic]       AS b,
          [dbo].[DrugStockMt]     AS c,
          [dbo].[DrugBatch]       AS d,
          [dbo].[PurchaseBasic]   AS e
     LEFT JOIN [dbo].[DrugTrialRecord] AS f ON f.CheckNo = @checkNo
    WHERE a.CheckNo    = @checkNo
      AND a.InStockNo  = @stockNo
      AND b.DrugCode   = a.DrugCode
      AND b.MedCode    = @medCode
      AND b.StartTime <= a.CheckTime
      AND b.EndTime   >= a.CheckTime
      AND c.StockNo    = a.InStockNo  
      AND c.DrugCode   = a.DrugCode
      AND d.BatchNo    = a.BatchNo
      AND e.ItemCode   = a.DrugCode
      AND e.ItemType   = @itemType     
      AND e.StartTime <= a.CheckTime
      AND e.EndTime   >= a.CheckTime
      FOR JSON PATH
END
GO

DECLARE @params NVARCHAR(MAX) =
'
{
  "checkNo": 465478,
  "stockNo": "1P11",
  "medCode": "ILEVOF7"
}
'

EXEC [dbo].[getDrugReviewInfos] @params
GO

