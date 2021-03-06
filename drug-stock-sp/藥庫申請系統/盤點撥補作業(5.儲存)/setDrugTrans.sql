USE [HealthResource]
GO

--- 程序名稱：setDrugTrans
--- 程序說明：設定藥品庫存交易
--- 編訂人員：蔡易志
--- 校閱人員：孫培然
--- 修訂日期：2021/07/28
CREATE PROCEDURE [dbo].[setDrugTrans](@params NVARCHAR(MAX))
AS BEGIN
   DECLARE @systemTime    DATETIME       = GETDATE();
   DECLARE @errorSeverity INT;
   DECLARE @tranNo        INT            = COALESCE(JSON_VALUE(@params, '$.tranNo'), 0);
   DECLARE @errorMessage  NVARCHAR(4000);
   DECLARE @procedureName VARCHAR(30)    = 'setDrugTrans';

   BEGIN TRY
         MERGE INTO [dbo].[DrugTrans] AS t
         USING ( SELECT *
                   FROM OPENJSON(@params)
                   WITH ( 
                          TranNo       INT      '$.tranNo',
                          DemandNo     INT      '$.demandNo',
                          TranType     TINYINT  '$.tranType',   
                          DrugCode     INT      '$.drugCode ',
                          InStockNo    CHAR(04) '$.inStockNo',
                          InStockUser  INT      '$.inStockUser',
                          InStockTime  DATETIME '$.inStockTime',      
                          OutStockNo   CHAR(04) '$.outStockNo',
                          OutStockUser INT      '$.outStockUser',
                          OutStockTime DATETIME '$.outStockTime',  
                          Qty          INT      '$.qty',
                          BatchNo      INT      '$.batchNo ',
                          SystemUser   INT      '$.systemUser',
                          SystemTime   DATETIME '$.systemTime'
                        )
               ) AS s   (
                          TranNo,      
                          DemandNo,    
                          TranType,   
                          DrugCode,     
                          InStockNo,   
                          InStockUser, 
                          InStockTime, 
                          OutStockNo,  
                          OutStockUser, 
                          OutStockTime,
                          Qty,         
                          BatchNo,     
                          SystemUser,  
                          SystemTime
                        ) 
              ON (t.TranNo = s.TranNo)    
         WHEN MATCHED THEN	  
              UPDATE SET	       
                     t.DemandNo     = ISNULL(s.DemandNo, t.DemandNo),     
                     t.TranType     = ISNULL(s.TranType, t.TranType),          
                     t.DrugCode     = ISNULL(s.DrugCode, t.DrugCode),    
                     t.InStockNo    = ISNULL(s.InStockNo, t.InStockNo),     
                     t.InStockUser  = ISNULL(s.InStockUser, t.InStockUser), 
                     t.InStockTime  = ISNULL(s.InStockTime, t.InStockTime), 
                     t.OutStockNo   = ISNULL(s.OutStockNo, t.OutStockNo), 
                     t.OutStockUser = ISNULL(s.OutStockUser, t.OutStockUser),
                     t.OutStockTime = ISNULL(s.OutStockTime, t.OutStockTime),
                     t.Qty          = ISNULL(s.Qty, t.Qty),         
                     t.BatchNo      = ISNULL(s.BatchNo, t.BatchNo),     
                     t.SystemUser   = s.SystemUser, 
                     t.SystemTime   = @systemTime
         WHEN NOT MATCHED THEN
              INSERT (
                       DemandNo,    
                       TranType,    
                       DrugCode,    
                       InStockNo,   
                       InStockUser, 
                       InStockTime, 
                       OutStockNo,  
                       OutStockUser,
                       OutStockTime,
                       Qty,         
                       BatchNo,     
                       SystemUser,  
                       SystemTime  
                     )
              VALUES (
                       s.DemandNo,    
                       s.TranType,    
                       s.DrugCode,    
                       s.InStockNo,   
                       s.InStockUser, 
                       s.InStockTime, 
                       s.OutStockNo,  
                       s.OutStockUser,
                       s.OutStockTime,
                       s.Qty,         
                       s.BatchNo,     
                       s.SystemUser,  
                       @systemTime
                     );
              IF (@tranNo = 0) SET @tranNo = @@IDENTITY;

   END TRY
   BEGIN CATCH
         SELECT @errorSeverity = ERROR_SEVERITY(), @errorMessage = ERROR_MESSAGE();
         EXEC [dbo].[setErrorLog] @procedureName, @params, @errorSeverity, @errorMessage;
         
         THROW;
   END CATCH
   RETURN @tranNo
END
GO

DECLARE @params NVARCHAR(max) = 
'
{
    "tranNo": 1996589,
    "demandNo": 4,
    "tranType": 2,
    "drugCode": 3675,
    "inStockNo": "1P11",
    "inStockUser": 25,
    "inStockTime": "2021-04-06 14:15:00",
    "outStockNo": "1A8D",
    "outStockUser": 30,
    "outStockTime": "2021-07-05 17:15:00",
    "qty": 40,
    "batchNo": 14752,
    "systemUser": 37029
}
';

EXEC [dbo].[setDrugTrans] @params
GO
