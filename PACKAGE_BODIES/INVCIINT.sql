--------------------------------------------------------
--  DDL for Package Body INVCIINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVCIINT" as
/* $Header: INVICOIB.pls 120.6.12010000.3 2009/02/12 00:45:47 yawang ship $ */

TYPE SegOrderArray IS TABLE OF Number INDEX BY BINARY_INTEGER;


PROCEDURE Load_Cust_Item(ERRBUF OUT NOCOPY VARCHAR2,
                  RETCODE OUT NOCOPY VARCHAR2,
                  ARGUMENT1 IN VARCHAR2,
                  ARGUMENT2 IN VARCHAR2) IS

        L_Retcode Number;
        CONC_STATUS BOOLEAN;

    --3537282 : Gather stats before running
    l_schema          VARCHAR2(30);
    l_status          VARCHAR2(1);
    l_industry        VARCHAR2(1);
    l_records         NUMBER(10);

BEGIN

   --Start 3537282 : Gather stats before running
   IF fnd_global.conc_program_id <> -1 THEN

       SELECT count(*) INTO l_records
       FROM   mtl_ci_interface
       WHERE  process_flag = 1;
   -- Bug 6983407 Collect statistics only if the no. of records is bigger than the profile
   -- option threshold
      IF l_records > nvl(fnd_profile.value('EGO_GATHER_STATS'),100) AND FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema)   THEN
         IF l_schema IS NOT NULL    THEN
            FND_STATS.GATHER_TABLE_STATS(l_schema, 'MTL_CI_INTERFACE');
          END IF;
       END IF;
   END IF;
   --End 3537282 : Gather stats before running


        L_Retcode := Load_Cust_Items_Iface(argument1,
                                        argument2);

        if L_Retcode = 1 then
                RETCODE := 'Success';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);
        elsif L_Retcode = 3 then
                RETCODE := 'Warning';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);
        else
                RETCODE := 'Error';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
        end if;

END Load_Cust_Item;


FUNCTION Load_Cust_Items_Iface(
                Abort_On_Error  IN      Varchar2        DEFAULT 'No',
                Delete_Record   IN      Varchar2        DEFAULT 'Yes'
        )  RETURN Number IS

        L_Success Number := 1;

        CURSOR  CI_Cur IS
        SELECT  Rowid Row_Id,
                        Process_Mode,
                        Customer_Name,
                        Customer_Number,
                        Customer_Id,
                        Customer_Category_Code,
                        Customer_Category,
                        Address1,
                        Address2,
                        Address3,
                        Address4,
                        City,
                        State,
                        County,
                        Country,
                        Postal_Code,
                        Address_Id,
                        trim(Customer_Item_Number) Customer_Item_Number,  --5622573
                        Item_Definition_Level_Desc,
                        Item_Definition_Level,
                        Customer_Item_Desc,
                        Model_Customer_Item_Number,
                        Model_Customer_Item_Id,
                        Commodity_Code,
                        Commodity_Code_Id,
                        Master_Container_Segment1,
                        Master_Container_Segment2,
                        Master_Container_Segment3,
                        Master_Container_Segment4,
                        Master_Container_Segment5,
                        Master_Container_Segment6,
                        Master_Container_Segment7,
                        Master_Container_Segment8,
                        Master_Container_Segment9,
                        Master_Container_Segment10,
                        Master_Container_Segment11,
                        Master_Container_Segment12,
                        Master_Container_Segment13,
                        Master_Container_Segment14,
                        Master_Container_Segment15,
                        Master_Container_Segment16,
                        Master_Container_Segment17,
                        Master_Container_Segment18,
                        Master_Container_Segment19,
                        Master_Container_Segment20,
                        Master_Container,
                        Master_Container_Item_Id,
                        Container_Item_Org_Name,
                        Container_Item_Org_Code,
                        Container_Item_Org_Id,
                        Detail_Container_Segment1,
                        Detail_Container_Segment2,
                        Detail_Container_Segment3,
                        Detail_Container_Segment4,
                        Detail_Container_Segment5,
                        Detail_Container_Segment6,
                        Detail_Container_Segment7,
                        Detail_Container_Segment8,
                        Detail_Container_Segment9,
                        Detail_Container_Segment10,
                        Detail_Container_Segment11,
                        Detail_Container_Segment12,
                        Detail_Container_Segment13,
                        Detail_Container_Segment14,
                        Detail_Container_Segment15,
                        Detail_Container_Segment16,
                        Detail_Container_Segment17,
                        Detail_Container_Segment18,
                        Detail_Container_Segment19,
                        Detail_Container_Segment20,
                        Detail_Container,
                        Detail_Container_Item_Id,
                        Min_Fill_Percentage,
                        Dep_Plan_Required_Flag,
                        Dep_Plan_Prior_Bld_Flag,
                        Inactive_Flag,
                        Attribute_Category,
                        Attribute1,
                        Attribute2,
                        Attribute3,
                        Attribute4,
                        Attribute5,
                        Attribute6,
                        Attribute7,
                        Attribute8,
                        Attribute9,
                        Attribute10,
                        Attribute11,
                        Attribute12,
                        Attribute13,
                        Attribute14,
                        Attribute15,
                        Demand_Tolerance_Positive,
                        Demand_Tolerance_Negative,
                        Last_Update_Date,
                        Last_Updated_By,
                        Creation_Date,
                        Created_By,
                        Last_Update_Login,
                        Request_Id,
                        Program_Application_Id,
                        Program_Id,
                        Program_Update_Date
        FROM            MTL_CI_INTERFACE
        WHERE           Process_Flag            =       1
        AND             Process_Mode            =       1
        OR              Process_Mode            =       3
        AND             UPPER(Transaction_Type) =       'CREATE'
        ORDER BY        Model_Customer_Item_Id, Model_Customer_Item_Number
        FOR UPDATE NOWAIT;

        Recinfo CI_Cur%ROWTYPE;

        Error_Number    Number          :=      NULL;
        Error_Message   Varchar2(2000)  :=      NULL;
        Error_Counter   Number          :=      0;
        Curr_Error              Varchar2(9)             :=      'APP-00000';

BEGIN

        OPEN CI_Cur;

        While (UPPER(Abort_On_Error) <> 'Y' or
                Error_Counter <= 0) LOOP

                FETCH CI_Cur INTO Recinfo;

                EXIT WHEN CI_Cur%NOTFOUND;

                BEGIN

                        IF (Recinfo.Process_Mode = 1) THEN

                           Validate_Customer_Item(
                                Recinfo.Row_Id, Recinfo.Process_Mode,
                                Recinfo.Customer_Name,
                                Recinfo.Customer_Number,
                                Recinfo.Customer_Id,
                                Recinfo.Customer_Category_Code,
                                Recinfo.Customer_Category,
                                Recinfo.Address1, Recinfo.Address2,
                                Recinfo.Address3, Recinfo.Address4,
                                Recinfo.City, Recinfo.State,
                                Recinfo.County, Recinfo.Country,
                                Recinfo.Postal_Code, Recinfo.Address_Id,
                                Recinfo.Customer_Item_Number,
                                Recinfo.Item_Definition_Level_Desc,
                                Recinfo.Item_Definition_Level,
                                Recinfo.Customer_Item_Desc,
                                Recinfo.Model_Customer_Item_Number,
                                Recinfo.Model_Customer_Item_Id,
                                Recinfo.Commodity_Code,
                                Recinfo.Commodity_Code_Id,
                                Recinfo.Master_Container_Segment1,
                                Recinfo.Master_Container_Segment2,
                                Recinfo.Master_Container_Segment3,
                                Recinfo.Master_Container_Segment4,
                                Recinfo.Master_Container_Segment5,
                                Recinfo.Master_Container_Segment6,
                                Recinfo.Master_Container_Segment7,
                                Recinfo.Master_Container_Segment8,
                                Recinfo.Master_Container_Segment9,
                                Recinfo.Master_Container_Segment10,
                                Recinfo.Master_Container_Segment11,
                                Recinfo.Master_Container_Segment12,
                                Recinfo.Master_Container_Segment13,
                                Recinfo.Master_Container_Segment14,
                                Recinfo.Master_Container_Segment15,
                                Recinfo.Master_Container_Segment16,
                                Recinfo.Master_Container_Segment17,
                                Recinfo.Master_Container_Segment18,
                                Recinfo.Master_Container_Segment19,
                                Recinfo.Master_Container_Segment20,
                                Recinfo.Master_Container,
                                Recinfo.Master_Container_Item_Id,
                                Recinfo.Container_Item_Org_Name,
                                Recinfo.Container_Item_Org_Code,
                                Recinfo.Container_Item_Org_Id,
                                Recinfo.Detail_Container_Segment1,
                                Recinfo.Detail_Container_Segment2,
                                Recinfo.Detail_Container_Segment3,
                                Recinfo.Detail_Container_Segment4,
                                Recinfo.Detail_Container_Segment5,
                                Recinfo.Detail_Container_Segment6,
                                Recinfo.Detail_Container_Segment7,
                                Recinfo.Detail_Container_Segment8,
                                Recinfo.Detail_Container_Segment9,
                                Recinfo.Detail_Container_Segment10,
                                Recinfo.Detail_Container_Segment11,
                                Recinfo.Detail_Container_Segment12,
                                Recinfo.Detail_Container_Segment13,
                                Recinfo.Detail_Container_Segment14,
                                Recinfo.Detail_Container_Segment15,
                                Recinfo.Detail_Container_Segment16,
                                Recinfo.Detail_Container_Segment17,
                                Recinfo.Detail_Container_Segment18,
                                Recinfo.Detail_Container_Segment19,
                                Recinfo.Detail_Container_Segment20,
                                Recinfo.Detail_Container,
                                Recinfo.Detail_Container_Item_Id,
                                Recinfo.Min_Fill_Percentage,
                                Recinfo.Dep_Plan_Required_Flag,
                                Recinfo.Dep_Plan_Prior_Bld_Flag,
                                Recinfo.Inactive_Flag,
                                Recinfo.Attribute_Category,
                                Recinfo.Attribute1, Recinfo.Attribute2,
                                Recinfo.Attribute3, Recinfo.Attribute4,
                                Recinfo.Attribute5, Recinfo.Attribute6,
                                Recinfo.Attribute7, Recinfo.Attribute8,
                                Recinfo.Attribute9, Recinfo.Attribute10,
                                Recinfo.Attribute11, Recinfo.Attribute12,
                                Recinfo.Attribute13, Recinfo.Attribute14,
                                Recinfo.Attribute15,
                                Recinfo.Demand_Tolerance_Positive,
                                Recinfo.Demand_Tolerance_Negative,
                                Recinfo.Last_Update_Date,
                                Recinfo.Last_Updated_By,
                                Recinfo.Creation_Date,
                                Recinfo.Created_By,
                                Recinfo.Last_Update_Login,
                                nvl(Recinfo.Request_Id, fnd_global.conc_request_id),
                                nvl(Recinfo.Program_Application_Id, fnd_global.prog_appl_id),
                                nvl(Recinfo.Program_Id, fnd_global.conc_program_id),
                                nvl(Recinfo.Program_Update_Date, sysdate),
                                Delete_Record );
/*
                                if L_Success = 1 then
                                        COMMIT;
                                end if;
*/
                                ELSIF (Recinfo.Process_Mode = 3) THEN

                                        Delete_Row('I', Delete_Record,
                                                        Recinfo.Row_Id);
/*
                                        if L_Success = 1 then
                                                COMMIT;
                                        end if;
*/
                                ELSE
                                        NULL;
                                END IF;

                EXCEPTION
                  WHEN Error THEN

                        L_Success := 3;
                        Error_Counter := Error_Counter + 1;
                        FND_MESSAGE.Set_Token('TABLE',
                                        'MTL_CI_INTERFACE', FALSE);
                        Error_Message := FND_MESSAGE.Get;
                        Manage_Error_Code('OUT', NULL, Curr_Error);

                        UPDATE  MTL_CI_INTERFACE MCII
                        SET     MCII.Error_Code = Curr_Error,
                                MCII.Error_Explanation  = substrb(Error_Message,1,235),
                                MCII.Process_Mode =     2
                        WHERE   MCII.Rowid = Recinfo.Row_Id;
/*
                        COMMIT;
*/
                 WHEN OTHERS THEN

                        L_Success := 2;
                        Error_Number  := SQLCODE;
                        Error_Message := SUBSTRB(SQLERRM, 1, 512);

                        UPDATE  MTL_CI_INTERFACE MCII
                        SET     MCII.Error_Code = TO_CHAR(Error_Number),
                                MCII.Error_Explanation  = substrb(Error_Message,1,235),
                                MCII.Process_Mode = 2
                        WHERE   MCII.Rowid = Recinfo.Row_Id;
/*
                        COMMIT;
*/
                        Raise;
                END;

        END LOOP;

        CLOSE CI_Cur;

        IF (Error_Counter > 0) THEN
                L_Success := 3;
                FND_MESSAGE.Set_Name('INV', 'INV_CI_OPEN_INT_WARNING');
                FND_MESSAGE.Set_Token('TABLE', 'MTL_CI_INTERFACE', FALSE);
                FND_MESSAGE.Set_Token('ERROR_COUNT', Error_Counter, FALSE);
                Error_Message   :=      FND_MESSAGE.Get;
                --DBMS_OUTPUT.Put_Line(Error_Message);
        END IF;

        COMMIT;

        Return L_Success;

EXCEPTION

        WHEN Error THEN

                L_Success := 3;
                Error_Counter   :=      Error_Counter + 1;
                FND_MESSAGE.Set_Token('TABLE', 'MTL_CI_INTERFACE', FALSE);
                Error_Message   :=      FND_MESSAGE.Get;
                Manage_Error_Code('OUT', NULL, Curr_Error);

                UPDATE  MTL_CI_INTERFACE MCII
                SET     MCII.Error_Code = Curr_Error,
                        MCII.Error_Explanation = substrb(Error_Message,1,235),
                        MCII.Process_Mode = 2
                WHERE   MCII.Rowid = Recinfo.Row_Id;

                COMMIT;

                Return L_Success;

        WHEN OTHERS THEN

                L_Success := 2;
                Error_Counter   := Error_Counter + 1;
                Error_Number    := SQLCODE;
                Error_Message   := SUBSTRB(SQLERRM, 1, 512);

		/* Fix for bug 5263099 - Added the below code to handle the scenario
		   where Cursor CI_Cur fails to open because the rows in
 		   MTL_CI_INTERFACE are already locked by some other session.
		   It leads to "ORA-00054-resource busy and acquire with NOWAIT specified" error.
		   So we check for this error condition SQLCODE= -54.
		   Manage_Error_Code will set the Current_Error_Code to the corresponding
		   error msg which shall then be shown in the conc prog log file.
		*/
		If SQLCODE= -54 Then
			Manage_Error_Code('IN',substrb(Error_Message,1,235), Curr_Error);
		End If;

                UPDATE  MTL_CI_INTERFACE MCII
                SET     MCII.Error_Code = TO_CHAR(Error_Number),
                        MCII.Error_Explanation = substrb(Error_Message,1,235),
                        MCII.Process_Mode = 2
                WHERE   MCII.Rowid = Recinfo.Row_Id;

                COMMIT;

                Return L_Success;

END Load_Cust_Items_Iface;


PROCEDURE Validate_Customer_Item(
                Row_Id                          IN OUT  NOCOPY Varchar2,
                Process_Mode                    IN OUT  NOCOPY Number,
                Customer_Name                   IN OUT  NOCOPY Varchar2,
                Customer_Number                 IN OUT  NOCOPY Varchar2,
                Customer_Id                     IN OUT  NOCOPY Number,
                Customer_Category_Code          IN OUT  NOCOPY Varchar2,
                Customer_Category               IN OUT  NOCOPY Varchar2,
                Address1                        IN OUT  NOCOPY Varchar2,
                Address2                        IN OUT  NOCOPY Varchar2,
                Address3                        IN OUT  NOCOPY Varchar2,
                Address4                        IN OUT  NOCOPY Varchar2,
                City                            IN OUT  NOCOPY Varchar2,
                State                           IN OUT  NOCOPY Varchar2,
                County                          IN OUT  NOCOPY Varchar2,
                Country                         IN OUT  NOCOPY Varchar2,
                Postal_Code                     IN OUT  NOCOPY Varchar2,
                Address_Id                      IN OUT  NOCOPY Number,
                Customer_Item_Number            IN OUT  NOCOPY Varchar2,
                Item_Definition_Level_Desc      IN OUT  NOCOPY Varchar2,
                Item_Definition_Level           IN OUT  NOCOPY Number,
                Customer_Item_Desc              IN OUT  NOCOPY Varchar2,
                Model_Customer_Item_Number      IN OUT  NOCOPY Varchar2,
                Model_Customer_Item_Id          IN OUT  NOCOPY Number,
                Commodity_Code                  IN OUT  NOCOPY Varchar2,
                Commodity_Code_Id               IN OUT  NOCOPY Number,
                Master_Container_Segment1       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment2       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment3       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment4       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment5       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment6       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment7       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment8       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment9       IN OUT  NOCOPY Varchar2,
                Master_Container_Segment10      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment11      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment12      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment13      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment14      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment15      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment16      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment17      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment18      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment19      IN OUT  NOCOPY Varchar2,
                Master_Container_Segment20      IN OUT  NOCOPY Varchar2,
                Master_Container                IN OUT  NOCOPY Varchar2,
                Master_Container_Item_Id        IN OUT  NOCOPY Number,
                Container_Item_Org_Name         IN OUT  NOCOPY Varchar2,
                Container_Item_Org_Code         IN OUT  NOCOPY Varchar2,
                Container_Item_Org_Id           IN OUT  NOCOPY Number,
                Detail_Container_Segment1       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment2       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment3       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment4       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment5       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment6       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment7       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment8       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment9       IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment10      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment11      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment12      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment13      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment14      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment15      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment16      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment17      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment18      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment19      IN OUT  NOCOPY Varchar2,
                Detail_Container_Segment20      IN OUT  NOCOPY Varchar2,
                Detail_Container                IN OUT  NOCOPY Varchar2,
                Detail_Container_Item_Id        IN OUT  NOCOPY Number,
                Min_Fill_Percentage             IN OUT  NOCOPY Number,
                Dep_Plan_Required_Flag          IN OUT  NOCOPY Varchar2,
                Dep_Plan_Prior_Bld_Flag         IN OUT  NOCOPY Varchar2,
                Inactive_Flag                   IN OUT  NOCOPY Varchar2,
                Attribute_Category              IN OUT  NOCOPY Varchar2,
                Attribute1                      IN OUT  NOCOPY Varchar2,
                Attribute2                      IN OUT  NOCOPY Varchar2,
                Attribute3                      IN OUT  NOCOPY Varchar2,
                Attribute4                      IN OUT  NOCOPY Varchar2,
                Attribute5                      IN OUT  NOCOPY Varchar2,
                Attribute6                      IN OUT  NOCOPY Varchar2,
                Attribute7                      IN OUT  NOCOPY Varchar2,
                Attribute8                      IN OUT  NOCOPY Varchar2,
                Attribute9                      IN OUT  NOCOPY Varchar2,
                Attribute10                     IN OUT  NOCOPY Varchar2,
                Attribute11                     IN OUT  NOCOPY Varchar2,
                Attribute12                     IN OUT  NOCOPY Varchar2,
                Attribute13                     IN OUT  NOCOPY Varchar2,
                Attribute14                     IN OUT  NOCOPY Varchar2,
                Attribute15                     IN OUT  NOCOPY Varchar2,
                Demand_Tolerance_Positive       IN OUT  NOCOPY Number,
                Demand_Tolerance_Negative       IN OUT  NOCOPY Number,
                Last_Update_Date                IN OUT  NOCOPY Date,
                Last_Updated_By                 IN OUT  NOCOPY Number,
                Creation_Date                   IN OUT  NOCOPY Date,
                Created_By                      IN OUT  NOCOPY Number,
                Last_Update_Login               IN OUT  NOCOPY Number,
                Request_Id                      IN      Number,
                Program_Application_Id          IN      Number,
                Program_Id                      IN      Number,
                Program_Update_Date             IN      Date,
                Delete_Record                   IN      Varchar2 DEFAULT NULL
        )       IS
BEGIN

        Validate_CI_Def_Level (
                Item_Definition_Level, Item_Definition_Level_Desc,
                Customer_Id, Customer_Number, Customer_Name,
                Customer_Category_Code, Customer_Category,
                Address_Id, Address1, Address2, Address3,
                Address4, City, State, County, Country, Postal_Code);

        Validate_Commodity_Code(Commodity_Code_Id, Commodity_Code);

        Validate_Inactive_Flag(Inactive_Flag);

        Validate_Concurrent_Program(Request_Id, Program_Application_Id,
                Program_Id, Program_Update_Date);

        IF ((Master_Container_Item_Id IS NOT NULL)
                OR (Master_Container IS NOT NULL)
                OR (Master_Container_Segment1 IS NOT NULL)
                OR (Master_Container_Segment2 IS NOT NULL)
                OR (Master_Container_Segment3 IS NOT NULL)
                OR (Master_Container_Segment4 IS NOT NULL)
                OR (Master_Container_Segment5 IS NOT NULL)
                OR (Master_Container_Segment6 IS NOT NULL)
                OR (Master_Container_Segment7 IS NOT NULL)
                OR (Master_Container_Segment8 IS NOT NULL)
                OR (Master_Container_Segment9 IS NOT NULL)
                OR (Master_Container_Segment10 IS NOT NULL)
                OR (Master_Container_Segment11 IS NOT NULL)
                OR (Master_Container_Segment12 IS NOT NULL)
                OR (Master_Container_Segment13 IS NOT NULL)
                OR (Master_Container_Segment14 IS NOT NULL)
                OR (Master_Container_Segment15 IS NOT NULL)
                OR (Master_Container_Segment16 IS NOT NULL)
                OR (Master_Container_Segment17 IS NOT NULL)
                OR (Master_Container_Segment18 IS NOT NULL)
                OR (Master_Container_Segment19 IS NOT NULL)
                OR (Master_Container_Segment20 IS NOT NULL)
                OR (Detail_Container_Item_Id IS NOT NULL)
                OR (Detail_Container IS NOT NULL)
                OR (Detail_Container_Segment1 IS NOT NULL)
                OR (Detail_Container_Segment2 IS NOT NULL)
                OR (Detail_Container_Segment3 IS NOT NULL)
                OR (Detail_Container_Segment4 IS NOT NULL)
                OR (Detail_Container_Segment5 IS NOT NULL)
                OR (Detail_Container_Segment6 IS NOT NULL)
                OR (Detail_Container_Segment7 IS NOT NULL)
                OR (Detail_Container_Segment8 IS NOT NULL)
                OR (Detail_Container_Segment9 IS NOT NULL)
                OR (Detail_Container_Segment10 IS NOT NULL)
                OR (Detail_Container_Segment11 IS NOT NULL)
                OR (Detail_Container_Segment12 IS NOT NULL)
                OR (Detail_Container_Segment13 IS NOT NULL)
                OR (Detail_Container_Segment14 IS NOT NULL)
                OR (Detail_Container_Segment15 IS NOT NULL)
                OR (Detail_Container_Segment16 IS NOT NULL)
                OR (Detail_Container_Segment17 IS NOT NULL)
                OR (Detail_Container_Segment18 IS NOT NULL)
                OR (Detail_Container_Segment19 IS NOT NULL)
                OR (Detail_Container_Segment20 IS NOT NULL)) THEN

                IF ((Container_Item_Org_Id IS NOT NULL)
                        OR (Container_Item_Org_Code IS NOT NULL)
                        OR (Container_Item_Org_Name IS NOT NULL)) THEN

                        Validate_Master_Organization(Container_Item_Org_Id,
                                Container_Item_Org_Code,
                                Container_Item_Org_Name);

                        IF ((Detail_Container_Item_Id IS NOT NULL)
                                OR (Detail_Container IS NOT NULL)
                                OR (Detail_Container_Segment1 IS NOT NULL)
                                OR (Detail_Container_Segment2 IS NOT NULL)
                                OR (Detail_Container_Segment3 IS NOT NULL)
                                OR (Detail_Container_Segment4 IS NOT NULL)
                                OR (Detail_Container_Segment5 IS NOT NULL)
                                OR (Detail_Container_Segment6 IS NOT NULL)
                                OR (Detail_Container_Segment7 IS NOT NULL)
                                OR (Detail_Container_Segment8 IS NOT NULL)
                                OR (Detail_Container_Segment9 IS NOT NULL)
                                OR (Detail_Container_Segment10 IS NOT NULL)
                                OR (Detail_Container_Segment11 IS NOT NULL)
                                OR (Detail_Container_Segment12 IS NOT NULL)
                                OR (Detail_Container_Segment13 IS NOT NULL)
                                OR (Detail_Container_Segment14 IS NOT NULL)
                                OR (Detail_Container_Segment15 IS NOT NULL)
                                OR (Detail_Container_Segment16 IS NOT NULL)
                                OR (Detail_Container_Segment17 IS NOT NULL)
                                OR (Detail_Container_Segment18 IS NOT NULL)
                                OR (Detail_Container_Segment19 IS NOT NULL)
                                OR (Detail_Container_Segment20 IS NOT NULL)
                                AND (Curr_Error = 'APP-00000')) THEN

                                Validate_Containers(Detail_Container_Item_Id,
                                        Detail_Container,
                                        Detail_Container_Segment1,
                                        Detail_Container_Segment2,
                                        Detail_Container_Segment3,
                                        Detail_Container_Segment4,
                                        Detail_Container_Segment5,
                                        Detail_Container_Segment6,
                                        Detail_Container_Segment7,
                                        Detail_Container_Segment8,
                                        Detail_Container_Segment9,
                                        Detail_Container_Segment10,
                                        Detail_Container_Segment11,
                                        Detail_Container_Segment12,
                                        Detail_Container_Segment13,
                                        Detail_Container_Segment14,
                                        Detail_Container_Segment15,
                                        Detail_Container_Segment16,
                                        Detail_Container_Segment17,
                                        Detail_Container_Segment18,
                                        Detail_Container_Segment19,
                                        Detail_Container_Segment20,
                                        Container_Item_Org_Id);

                                IF ((Master_Container_Item_Id IS NOT NULL)
                                        OR (Master_Container IS NOT NULL)
                                        OR (Master_Container_Segment1 IS NOT NULL)
                                        OR (Master_Container_Segment2 IS NOT NULL)
                                        OR (Master_Container_Segment3 IS NOT NULL)
                                        OR (Master_Container_Segment4 IS NOT NULL)
                                        OR (Master_Container_Segment5 IS NOT NULL)
                                        OR (Master_Container_Segment6 IS NOT NULL)
                                        OR (Master_Container_Segment7 IS NOT NULL)
                                        OR (Master_Container_Segment8 IS NOT NULL)
                                        OR (Master_Container_Segment9 IS NOT NULL)
                                        OR (Master_Container_Segment10 IS NOT NULL)
                                        OR (Master_Container_Segment11 IS NOT NULL)
                                        OR (Master_Container_Segment12 IS NOT NULL)
                                        OR (Master_Container_Segment13 IS NOT NULL)
                                        OR (Master_Container_Segment14 IS NOT NULL)
                                        OR (Master_Container_Segment15 IS NOT NULL)
                                        OR (Master_Container_Segment16 IS NOT NULL)
                                        OR (Master_Container_Segment17 IS NOT NULL)
                                        OR (Master_Container_Segment18 IS NOT NULL)
                                        OR (Master_Container_Segment19 IS NOT NULL)
                                        OR (Master_Container_Segment20 IS NOT NULL)
                                        AND (Curr_Error = 'APP-00C03')
                                        OR (Curr_Error = 'APP-00000')) THEN

                                        Validate_Containers(
                                                Master_Container_Item_Id,
                                                Master_Container,
                                                Master_Container_Segment1,
                                                Master_Container_Segment2,
                                                Master_Container_Segment3,
                                                Master_Container_Segment4,
                                                Master_Container_Segment5,
                                                Master_Container_Segment6,
                                                Master_Container_Segment7,
                                                Master_Container_Segment8,
                                                Master_Container_Segment9,
                                                Master_Container_Segment10,
                                                Master_Container_Segment11,
                                                Master_Container_Segment12,
                                                Master_Container_Segment13,
                                                Master_Container_Segment14,
                                                Master_Container_Segment15,
                                                Master_Container_Segment16,
                                                Master_Container_Segment17,
                                                Master_Container_Segment18,
                                                Master_Container_Segment19,
                                                Master_Container_Segment20,
                                                Container_Item_Org_Id);

                                ELSE
                                        FND_MESSAGE.Set_Name('INV',
                                                'INV_NO_MASTER_CONTAINER');
                                        Manage_Error_Code('IN', 'APP-43049',
                                                Curr_Error);
                                        RAISE Error;
                                END IF;
                        ELSE
                                Validate_Containers(Master_Container_Item_Id,
                                        Master_Container,
                                        Master_Container_Segment1,
                                        Master_Container_Segment2,
                                        Master_Container_Segment3,
                                        Master_Container_Segment4,
                                        Master_Container_Segment5,
                                        Master_Container_Segment6,
                                        Master_Container_Segment7,
                                        Master_Container_Segment8,
                                        Master_Container_Segment9,
                                        Master_Container_Segment10,
                                        Master_Container_Segment11,
                                        Master_Container_Segment12,
                                        Master_Container_Segment13,
                                        Master_Container_Segment14,
                                        Master_Container_Segment15,
                                        Master_Container_Segment16,
                                        Master_Container_Segment17,
                                        Master_Container_Segment18,
                                        Master_Container_Segment19,
                                        Master_Container_Segment20,
                                        Container_Item_Org_Id);
                        END IF;
                ELSE

                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ORGANIZATION');
                        FND_MESSAGE.Set_Token('COLUMN1',
                                'MASTER_ORGANIZATION_ID', FALSE);
                        FND_MESSAGE.Set_Token('COLUMN2',
                                'MASTER_ORGANIZATION_CODE', FALSE);
                        FND_MESSAGE.Set_Token('COLUMN3',
                                'MASTER_ORGANIZATION_NAME', FALSE);
                        Manage_Error_Code('IN', 'APP-43045', Curr_Error);
                        RAISE Error;
                END IF;
        ELSE
                NULL;
        END IF;

        Validate_Model(Model_Customer_Item_Id, Model_Customer_Item_Number,
                        Customer_Id, Address_Id, Customer_Category_Code,
                        Item_Definition_Level, Customer_Item_Number);

        Validate_Demand_Tolerance(Demand_Tolerance_Positive);

        Validate_Demand_Tolerance(Demand_Tolerance_Negative);

        Validate_Fill_Percentage(Min_Fill_Percentage);

        Validate_Departure_Plan_Flags(Dep_Plan_Required_Flag,
                        Dep_Plan_Prior_Bld_Flag);

        Check_Required_Columns('I', Customer_Id, Customer_Item_Number,
                        Item_Definition_Level, Customer_Category_Code,
                        Address_Id, Inactive_Flag, Last_Updated_By,
                        Last_Update_Date, Created_By, Creation_Date,
                        NULL, NULL, NULL, NULL);

        Check_Uniqueness('I', Customer_Id, Customer_Item_Number,
                        Item_Definition_Level, Customer_Category_Code,
                        Address_Id, NULL, NULL, NULL, NULL);

        Insert_Row('I', Last_Update_Date, Last_Updated_By, Creation_Date,
                        Created_By, Last_Update_Login, Customer_Id,
                        Customer_Category_Code, Address_Id,
                        Customer_Item_Number, Item_Definition_Level,
                        Customer_Item_Desc, Model_Customer_Item_Id,
                        Commodity_Code_Id, Master_Container_Item_Id,
                        Container_Item_Org_Id, Detail_Container_Item_Id,
                        Min_Fill_Percentage, Dep_Plan_Required_Flag,
                        Dep_Plan_Prior_Bld_Flag, Inactive_Flag,
                        Attribute_Category, Attribute1, Attribute2,
                        Attribute3, Attribute4, Attribute5, Attribute6,
                        Attribute7, Attribute8, Attribute9, Attribute10,
                        Attribute11, Attribute12, Attribute13, Attribute14,
                        Attribute15, Demand_Tolerance_Positive,
                        Demand_Tolerance_Negative, Request_Id,
                        Program_Application_Id, Program_Id,
                        Program_Update_Date, NULL, NULL, NULL, NULL);

        Delete_Row('I', Delete_Record, Row_Id);

END Validate_Customer_Item;


PROCEDURE Validate_CI_Def_Level (       P_Item_Definition_Level         IN OUT  NOCOPY Varchar2,
                                        P_Item_Definition_Level_Desc    IN      Varchar2        DEFAULT NULL,
                                        P_Customer_Id                   IN OUT  NOCOPY Number,
                                        P_Customer_Number               IN OUT  NOCOPY Varchar2,
                                        P_Customer_Name                 IN OUT  NOCOPY Varchar2,
                                        P_Customer_Category_Code        IN OUT  NOCOPY Varchar2,
                                        P_Customer_Category             IN OUT  NOCOPY Varchar2,
                                        P_Address_Id                    IN OUT  NOCOPY Number,
                                        P_Address1                      IN OUT  NOCOPY Varchar2,
                                        P_Address2                      IN OUT  NOCOPY Varchar2,
                                        P_Address3                      IN OUT  NOCOPY Varchar2,
                                        P_Address4                      IN OUT  NOCOPY Varchar2,
                                        P_City                          IN OUT  NOCOPY Varchar2,
                                        P_State                         IN OUT  NOCOPY Varchar2,
                                        P_County                        IN OUT  NOCOPY Varchar2,
                                        P_Country                       IN OUT  NOCOPY Varchar2,
                                        P_Postal_Code                   IN OUT  NOCOPY Varchar2        )       IS

Temp_Lookup_Code        Number          :=      NULL;
Temp_Meaning            Varchar2(80)    :=      NULL;

BEGIN

        IF (P_Item_Definition_Level IS NOT NULL) THEN

                IF (P_Item_Definition_Level = '1') THEN

                        Validate_Customer (P_Customer_Id, P_Customer_Number, P_Customer_Name);

                        P_Address_Id                    :=      NULL;

                        P_Customer_Category_Code        :=      NULL;

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);


                ELSIF (P_Item_Definition_Level = '2') THEN

                        Validate_Customer (P_Customer_Id, P_Customer_Number, P_Customer_Name);

                        Validate_Address_Category (P_Customer_Category_Code, P_Customer_Category);

                        P_Address_Id                    :=      NULL;

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);


                ELSIF (P_Item_Definition_Level = '3') THEN

                        Validate_Customer (P_Customer_Id, P_Customer_Number, P_Customer_Name);

                        Validate_Address (P_Address_Id, P_Customer_Id, P_Address1, P_Address2, P_Address3, P_Address4,
                         P_City, P_State, P_County, P_Country, P_Postal_Code);

                        P_Customer_Category_Code        :=      NULL;

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);

                ELSE

                        FND_MESSAGE.Set_Name('INV', 'INV_INVALID_ITEM_DEF_LEVEL');
                        FND_MESSAGE.Set_Token('COLUMN', 'ITEM_DEFINITION_LEVEL', FALSE);
                        Manage_Error_Code('IN', 'APP-43000', Curr_Error);
                        RAISE Error;

                END IF;

        ELSIF ((P_Item_Definition_Level IS NULL) AND (P_Item_Definition_Level_Desc IS NOT NULL)) THEN

                SELECT  Lookup_Code, Meaning
                INTO            Temp_Lookup_Code, Temp_Meaning
                FROM            MFG_LOOKUPS MFGL
                WHERE           UPPER(MFGL.Meaning)             =       UPPER(P_Item_Definition_Level_Desc)
                AND             MFGL.Lookup_Type                =       'INV_ITEM_DEFINITION_LEVEL';

                IF (Temp_Lookup_Code = 1) THEN

                        Validate_Customer (P_Customer_Id, P_Customer_Number, P_Customer_Name);

                        P_Address_Id                    :=      NULL;

                        P_Customer_Category_Code        :=      NULL;

                        P_Item_Definition_Level         :=      '1';

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);

                ELSIF (Temp_Lookup_Code = 2 ) THEN

                        Validate_Customer (P_Customer_Id, P_Customer_Number, P_Customer_Name);

                        Validate_Address_Category (P_Customer_Category_Code, P_Customer_Category);

                        P_Address_Id                    :=      NULL;

                        P_Item_Definition_Level         :=      '2';

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);

                ELSIF (Temp_Lookup_Code = 3) THEN

                        Validate_Customer (P_Customer_Id, P_Customer_Number, P_Customer_Name);

                        Validate_Address (P_Address_Id, P_Customer_Id, P_Address1, P_Address2, P_Address3, P_Address4,
                         P_City, P_State, P_County, P_Country, P_Postal_Code);

                        P_Customer_Category_Code        :=      NULL;

                        P_Item_Definition_Level         :=      '3';

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);

                ELSE

                        FND_MESSAGE.Set_Name('INV', 'INV_INVALID_ITEM_DEF_LEVEL');
                        FND_MESSAGE.Set_Token('COLUMN', 'ITEM_DEFINITION_LEVEL_DESC', FALSE);
                        Manage_Error_Code('IN', 'APP-43000', Curr_Error);
                        RAISE Error;

                END IF;

        ELSE

                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ITEM_DEF_LEVEL');
                        Manage_Error_Code('IN', 'APP-43001', Curr_Error);
                        RAISE Error;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_NO_SEED_DATA_ITEM_DEF');
                Manage_Error_Code('IN', 'APP-43047', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_ITEM_DEF');
                Manage_Error_Code('IN', 'APP-43048', Curr_Error);
                RAISE Error;

END Validate_CI_Def_Level;


PROCEDURE Validate_Customer     (       P_Customer_Id           IN OUT  NOCOPY Number,
                                        P_Customer_Number       IN      Varchar2        DEFAULT NULL,
                                        P_Customer_Name         IN      Varchar2        DEFAULT NULL    )       IS

Temp_Customer_Id        Number          :=      NULL;
Temp_Status             Varchar2(1)     :=      NULL;

BEGIN

        IF (P_Customer_Id IS NOT NULL) THEN
/**Bug: 2786267
                SELECT  Customer_Id, Status
                INTO            Temp_Customer_Id, Temp_Status
                FROM            RA_CUSTOMERS RAC
                WHERE           RAC.Customer_Id =       P_Customer_Id;
**/
                SELECT  CUST_ACCT.CUST_ACCOUNT_ID, CUST_ACCT.STATUS
                INTO    Temp_Customer_Id, Temp_Status
                FROM    HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
                WHERE   CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
                AND     CUST_ACCT.CUST_ACCOUNT_ID = P_Customer_Id;

                IF ((SQL%FOUND) AND (Temp_Status <> 'A')) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_INACTIVE_CUSTOMER');
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_ID', FALSE);
                        Manage_Error_Code('IN', 'APP-43002', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Customer_Id   :=      Temp_Customer_Id;
                        RETURN;

                END IF;

        ELSIF ((P_Customer_Id IS NULL) AND (P_Customer_Number IS NOT NULL)) THEN
/**Bug: 2786267
                SELECT  Customer_Id, Status
                INTO            Temp_Customer_Id, Temp_Status
                FROM            RA_CUSTOMERS RAC
                WHERE           RAC.Customer_Number     =       P_Customer_Number;
**/
                SELECT  CUST_ACCT.CUST_ACCOUNT_ID, CUST_ACCT.STATUS
                INTO    Temp_Customer_Id, Temp_Status
                FROM    HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
                WHERE   CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
                AND     CUST_ACCT.ACCOUNT_NUMBER = P_Customer_Number;

                IF ((SQL%FOUND) AND (Temp_Status <> 'A')) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_INACTIVE_CUSTOMER');
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_NUMBER', FALSE);
                        Manage_Error_Code('IN', 'APP-43002', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Customer_Id   :=      Temp_Customer_Id;
                        RETURN;

                END IF;

        ELSIF ((P_Customer_Id IS NULL) AND (P_Customer_Number IS NULL) AND (P_Customer_Name IS NOT NULL)) THEN
/**Bug: 2786267
                SELECT  Customer_Id, Status
                INTO            Temp_Customer_Id, Temp_Status
                FROM            RA_CUSTOMERS RAC
                WHERE           RAC.Customer_Name       =       P_Customer_Name;
**/
                SELECT  CUST_ACCT.CUST_ACCOUNT_ID, CUST_ACCT.STATUS
                INTO    Temp_Customer_Id, Temp_Status
                FROM    HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
                WHERE   CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
                AND     PARTY.PARTY_NAME like P_Customer_Name || '%';

                IF ((SQL%FOUND) AND (Temp_Status <> 'A')) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_INACTIVE_CUSTOMER');
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_NAME', FALSE);
                        Manage_Error_Code('IN', 'APP-43002', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Customer_Id   :=      Temp_Customer_Id;
                        RETURN;

                END IF;

        ELSE

                FND_MESSAGE.Set_Name('INV', 'INV_NO_CUSTOMER');
                Manage_Error_Code('IN', 'APP-43003', Curr_Error);
                RAISE Error;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_CUSTOMER');
                IF (P_Customer_Id IS NOT NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_ID', FALSE);
                ELSIF ((P_Customer_Id IS NULL) AND (P_Customer_Number IS NOT NULL)) THEN
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_NUMBER', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_NAME', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43004', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_CUSTOMERS');
                Manage_Error_Code('IN', 'APP-43005', Curr_Error);
                RAISE Error;

END Validate_Customer;


PROCEDURE Validate_Address      (       P_Address_Id    IN OUT     NOCOPY     Number,
                                        P_Customer_Id   IN              Number          DEFAULT NULL,
                                        P_Address1      IN              Varchar2        DEFAULT NULL,
                                        P_Address2      IN              Varchar2        DEFAULT NULL,
                                        P_Address3      IN              Varchar2        DEFAULT NULL,
                                        P_Address4      IN              Varchar2        DEFAULT NULL,
                                        P_City          IN              Varchar2        DEFAULT NULL,
                                        P_State         IN              Varchar2        DEFAULT NULL,
                                        P_County        IN              Varchar2        DEFAULT NULL,
                                        P_Country       IN              Varchar2        DEFAULT NULL,
                                        P_Postal_Code   IN              Varchar2        DEFAULT NULL    )       IS

Temp_Address_Id Number  :=      NULL;
Temp_Status             Varchar2(1)     :=      NULL;

BEGIN

        IF (P_Address_Id IS NOT NULL) THEN

          /* The RA_ADDRESSES view has been scrapped. Re-writing this query -Anmurali
		SELECT  Address_Id, Status
                INTO            Temp_Address_Id, Temp_Status
                FROM            RA_ADDRESSES RAA
                WHERE           RAA.Address_Id  =       P_Address_Id
                AND             RAA.Customer_Id =       P_Customer_Id;   */

                --Fix bug 8198434, remove reference to HZ_LOC_ASSIGNMENTS
		SELECT ACCT_SITE.CUST_ACCT_SITE_ID , ACCT_SITE.STATUS
		INTO   Temp_Address_Id, Temp_Status
	         FROM HZ_PARTY_SITES PARTY_SITE, --HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
                      HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
                 WHERE ACCT_SITE.CUST_ACCT_SITE_ID = P_Address_Id
		   AND ACCT_SITE.CUST_ACCOUNT_ID   = P_Customer_Id
	           AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
		   AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
	           --AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
		   --AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)
                   AND NVL(ACCT_SITE.ORG_ID,
		         NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
		                                                  SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99)) =
	                 NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ', NULL,
			                                          SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99);

                IF ((SQL%FOUND) AND (Temp_Status <> 'A')) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_INACTIVE_ADDRESS');
                        FND_MESSAGE.Set_Token('COLUMN', 'ADDRESS_ID', FALSE);
                        Manage_Error_Code('IN', 'APP-43006', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Address_Id    :=      Temp_Address_Id;
                        RETURN;

                END IF;

        ELSIF ((P_Address_Id IS NULL) AND (P_Customer_Id IS NOT NULL) AND
                ((P_Address1 IS NOT NULL) OR (P_Address2 IS NOT NULL) OR
                (P_Address3 IS NOT NULL) OR (P_Address4 IS NOT NULL) OR
                (P_City IS NOT NULL) OR (P_State IS NOT NULL) OR (P_County IS NOT NULL) OR
                (P_Country IS NOT NULL) OR (P_Postal_Code IS NOT NULL))) THEN

         /* The view RA_ADDRESSES has been scrapped, re-writing this query -Anmurali

		SELECT  Address_Id, Status
                INTO            Temp_Address_Id, Temp_Status
                FROM            RA_ADDRESSES RAA
                WHERE           NVL(RAA.Address1, ' ')          =       NVL(P_Address1, ' ')
                AND             NVL(RAA.Address2, ' ')          =       NVL(P_Address2, ' ')
                AND             NVL(RAA.Address3, ' ')          =       NVL(P_Address3, ' ')
                AND             NVL(RAA.Address4, ' ')          =       NVL(P_Address4, ' ')
                AND             NVL(RAA.City, ' ')              =       NVL(P_City, ' ')
                AND             NVL(RAA.State, ' ')             =       NVL(P_State, ' ')
                AND             NVL(RAA.County, ' ')            =       NVL(P_County, ' ')
                AND             NVL(RAA.Country, ' ')           =       NVL(P_Country, ' ')
                AND             NVL(RAA.Postal_Code, ' ')       =       NVL(P_Postal_Code, ' ')
                AND             RAA.Customer_Id                 =       P_Customer_Id; */

		SELECT ACCT_SITE.CUST_ACCT_SITE_ID , ACCT_SITE.STATUS
		INTO   Temp_Address_Id, Temp_Status
	        FROM HZ_PARTY_SITES PARTY_SITE, --HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
                     HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
		WHERE  ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
		   AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
	           --AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
		   --AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)
                   AND NVL(ACCT_SITE.ORG_ID,
		         NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
		                                                  SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99)) =
	                 NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ', NULL,
			                                          SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99)
                   AND NVL(LOC.Address1, ' ')          =       NVL(P_Address1, ' ')
                   AND NVL(LOC.Address2, ' ')          =       NVL(P_Address2, ' ')
                   AND NVL(LOC.Address3, ' ')          =       NVL(P_Address3, ' ')
                   AND NVL(LOC.Address4, ' ')          =       NVL(P_Address4, ' ')
                   AND NVL(LOC.City, ' ')              =       NVL(P_City, ' ')
                   AND NVL(LOC.State, ' ')             =       NVL(P_State, ' ')
                   AND NVL(LOC.County, ' ')            =       NVL(P_County, ' ')
                   AND NVL(LOC.Country, ' ')           =       NVL(P_Country, ' ')
                   AND NVL(LOC.Postal_Code, ' ')       =       NVL(P_Postal_Code, ' ')
                   AND ACCT_SITE.CUST_ACCOUNT_ID       =       P_Customer_Id;



                IF ((SQL%FOUND) AND (Temp_Status <> 'A')) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_INACTIVE_ADDRESS');
                        FND_MESSAGE.Set_Token('COLUMN', 'ADDRESS_ID', FALSE);
                        Manage_Error_Code('IN', 'APP-43006', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Address_Id    :=      Temp_Address_Id;
                        RETURN;

                END IF;

        ELSE

                FND_MESSAGE.Set_Name('INV', 'INV_NO_ADDRESS');
                Manage_Error_Code('IN', 'APP-43007', Curr_Error);
                RAISE Error;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_ADDRESS');
                IF (P_Address_Id IS NOT NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN', 'ADDRESS_ID', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN', 'ADDRESS1-4, CITY, STATE, ETC.', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43008', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_ADDRESSES');
                Manage_Error_Code('IN', 'APP-43009', Curr_Error);
                RAISE Error;

END Validate_Address;


PROCEDURE Validate_Address_Category     (       P_Customer_Category_Code        IN OUT  NOCOPY Varchar2,
                                                P_Customer_Category             IN      Varchar2        DEFAULT NULL    )       IS

Temp_Lookup_Code                Varchar2(80)    :=      NULL;
Temp_Enabled_Flag               Varchar2(1)     :=      NULL;
Temp_Start_Date_Active          Date            :=      NULL;
Temp_End_Date_Active            Date            :=      NULL;

BEGIN

        IF (P_Customer_Category_Code IS NOT NULL) THEN

                SELECT  ARL.Lookup_Code, ARL.Enabled_Flag, ARL.Start_Date_Active, ARL.End_Date_Active
                INTO            Temp_Lookup_Code, Temp_Enabled_Flag, Temp_Start_Date_Active, Temp_End_Date_Active
                FROM            AR_LOOKUPS ARL
                WHERE           ARL.Lookup_Code                 =       P_Customer_Category_Code
                AND             ARL.Lookup_Type                 =       'ADDRESS_CATEGORY'
                AND             rownum                          =       1;

                IF ((SQL%FOUND) AND (Temp_Enabled_Flag = 'N')) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_DISABLED_ADDR_CAT');
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_CATEGORY_CODE', FALSE);
                        Manage_Error_Code('IN', 'APP-43010', Curr_Error);
                        RAISE Error;

                ELSIF ((SQL%FOUND) AND NOT (TRUNC(SYSDATE) BETWEEN NVL(TRUNC((Temp_Start_Date_Active)),SYSDATE)AND NVL(TRUNC((Temp_End_Date_Active)), SYSDATE))) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_INACTIVE_ADDR_CAT');
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_CATEGORY_CODE', FALSE);
                        Manage_Error_Code('IN', 'APP-43011', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Customer_Category_Code        :=      Temp_Lookup_Code;
                        RETURN;

                END IF;

        ELSIF ((P_Customer_Category_Code IS NULL) AND (P_Customer_Category IS NOT NULL)) THEN

                SELECT  ARL.Lookup_Code, ARL.Enabled_Flag, ARL.Start_Date_Active, ARL.End_Date_Active
                INTO            Temp_Lookup_Code, Temp_Enabled_Flag, Temp_Start_Date_Active, Temp_End_Date_Active
                FROM            AR_LOOKUPS ARL
                WHERE           UPPER(ARL.Meaning)              =       UPPER(P_Customer_Category)
                AND             ARL.Lookup_Type                 =       'ADDRESS_CATEGORY'
                AND             rownum                          =       1;

                IF ((SQL%FOUND) AND (Temp_Enabled_Flag = 'N')) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_DISABLED_ADDR_CAT');
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_CATEGORY', FALSE);
                        Manage_Error_Code('IN', 'APP-43010', Curr_Error);
                        RAISE Error;

                ELSIF ((SQL%FOUND) AND NOT (TRUNC(SYSDATE) BETWEEN NVL(TRUNC((Temp_Start_Date_Active)),SYSDATE)AND NVL(TRUNC((Temp_End_Date_Active)), SYSDATE))) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_INACTIVE_ADDR_CAT');
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_CATEGORY', FALSE);
                        Manage_Error_Code('IN', 'APP-43011', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Customer_Category_Code        :=      Temp_Lookup_Code;
                        RETURN;

                END IF;

        ELSE

                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ADDR_CAT');
                        Manage_Error_Code('IN', 'APP-43012', Curr_Error);
                        RAISE Error;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_ADDR_CAT');
                IF (P_Customer_Category_Code IS NOT NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_CATEGORY_CODE', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_CATEGORY', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43013', Curr_Error);
                RAISE Error;

END Validate_Address_Category;


PROCEDURE Validate_Containers(
        P_Container_Item_Id             IN OUT  NOCOPY Number,
        P_Container_Item                IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment1       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment2       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment3       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment4       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment5       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment6       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment7       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment8       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment9       IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment10      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment11      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment12      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment13      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment14      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment15      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment16      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment17      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment18      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment19      IN      Varchar2        DEFAULT NULL,
        P_Container_Item_Segment20      IN      Varchar2        DEFAULT NULL,
        P_Container_Organization_Id     IN      Number          DEFAULT NULL
        )       IS

Temp_Container_Item_Id  Number := NULL;
Now Varchar2(20) := TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS');
Temp_Container_Item_Flag Varchar2(1) := NULL;
L_Segment_Array fnd_flex_ext.SegmentArray;
L_SegOrder_Array SegOrderArray;
L_TempSeg_Counter Number := 0;
L_Success Boolean;
L_Temp_Concat_Container Varchar2(2000);
L_FlexSeg_Counter Number := 0;

Cursor L_FlexSegOrder_Curr is
        SELECT segment_num from
        fnd_id_flex_segments
        where application_id = 401
        and id_flex_code = 'MSTK'
        and enabled_flag = 'Y'
        order by segment_num;

L_SegNumDummy Number;
L_SegNumIndex Number := 0;
L_Delimiter Varchar2(1) := NULL;
L_ConcatSegs Varchar2(2000) := NULL;
L_StructNum Number := NULL;

BEGIN

        IF (P_Container_Item_Id IS NOT NULL) THEN

                SELECT  Inventory_Item_Id
                INTO    Temp_Container_Item_Id
                FROM    MTL_SYSTEM_ITEMS MSI
                WHERE   MSI.Inventory_Item_Id = P_Container_Item_Id
                AND     MSI.Container_Item_Flag = 'Y'
                AND     MSI.Organization_Id = P_Container_Organization_Id;

                IF (SQL%FOUND) THEN

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Container_Item_Id := Temp_Container_Item_Id;
                        RETURN;

                END IF;

        ELSIF ((P_Container_Item_Id IS NULL) AND
               (P_Container_Item IS NOT NULL)) THEN


                BEGIN
                        SELECT ID_Flex_Num
                        INTO L_StructNum
                        FROM fnd_id_flex_structures
                        WHERE application_id = 401
                        AND id_flex_code = 'MSTK'
                        AND upper(enabled_flag) = 'Y';
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;

                   WHEN TOO_MANY_ROWS THEN
                        FND_MESSAGE.Set_Name('INV',
                                        'INV_MULT_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;
                END;

                L_Success := FND_FLEX_KEYVAL.Validate_Segs(
                                OPERATION       => 'FIND_COMBINATION',
                                APPL_SHORT_NAME => 'INV',
                                KEY_FLEX_CODE   => 'MSTK',
                                STRUCTURE_NUMBER=> L_StructNum,
                                CONCAT_SEGMENTS => P_Container_Item,
                                DATA_SET        => P_Container_Organization_Id,
                                WHERE_CLAUSE    =>
                                     'UPPER(MTL_SYSTEM_ITEMS.Container_Item_Flag) = ''Y'''
                        );

                if L_Success then
                        P_Container_Item_Id :=
                                FND_FLEX_KEYVAL.Combination_Id;

                else
                        P_Container_Item_Id := NULL;
                end if;

                If P_Container_Item_Id is NULL then

                        FND_MESSAGE.Set_Name('INV', 'INV_INVALID_CONTAINER');
                        FND_MESSAGE.Set_Token('COLUMN',
                                        'CONTAINER_ITEM', FALSE);
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;
                END IF;

        ELSIF ((P_Container_Item_Id IS NULL) AND
               (P_Container_Item IS NULL) ) THEN

                BEGIN
                        SELECT ID_Flex_Num
                        INTO L_StructNum
                        FROM fnd_id_flex_structures
                        WHERE application_id = 401
                        AND id_flex_code = 'MSTK'
                        AND upper(enabled_flag) = 'Y';
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;

                   WHEN TOO_MANY_ROWS THEN
                        FND_MESSAGE.Set_Name('INV',
                                        'INV_MULT_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;
                END;

                OPEN L_FlexSegOrder_Curr;

                LOOP
                        FETCH L_FlexSegOrder_Curr into L_SegNumDummy;
                        EXIT WHEN L_FlexSegOrder_Curr%NOTFOUND;

                        L_FlexSeg_Counter := L_FlexSeg_Counter+1;
                        L_Segment_Array(L_FlexSeg_Counter) := NULL;
                        L_SegOrder_Array(L_FlexSeg_Counter) := L_SegNumDummy;
                END LOOP;

                CLOSE L_FlexSegOrder_Curr;

                if P_Container_Item_Segment1 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT1';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT1',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment1;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;

                end if;

                if P_Container_Item_Segment2 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT2';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT2',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment2;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment3 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT3';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT3',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment3;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment4 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT4';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT4',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment4;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment5 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT5';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT5',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment5;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment6 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT6';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT6',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment6;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment7 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT7';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT7',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment7;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment8 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT8';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT8',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment8;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment9 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT9';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT9',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment9;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment10 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT10';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT10',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment10;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment11 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT11';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT11',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment11;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment12 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT12';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT12',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment12;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment13 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT13';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT13',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment13;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment14 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT14';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT14',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment14;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment15 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT15';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT15',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment15;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment16 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT16';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT16',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment16;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment17 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT17';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT17',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment17;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment18 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT18';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT18',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment18;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment19 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT19';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT19',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment19;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Container_Item_Segment20 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT20';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'CONTAINER_SEGMENT20',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Container_Item_Segment20;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                L_Delimiter := fnd_flex_ext.get_delimiter('INV',
                                                'MSTK',
                                                L_StructNum);

                if (L_TempSeg_Counter > 0) then

                        L_ConcatSegs := fnd_flex_ext.concatenate_segments(
                                        L_FlexSeg_Counter,
                                        L_Segment_Array,
                                        L_Delimiter);
                else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_MISMATCH');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                end if;

                if L_ConcatSegs is not null then

                        L_Success := FND_FLEX_KEYVAL.Validate_Segs(
                                OPERATION       => 'FIND_COMBINATION',
                                APPL_SHORT_NAME => 'INV',
                                KEY_FLEX_CODE   => 'MSTK',
                                STRUCTURE_NUMBER=> L_StructNum,
                                CONCAT_SEGMENTS => L_ConcatSegs,
                                DATA_SET        => P_Container_Organization_Id,
                                WHERE_CLAUSE    =>
                                     'UPPER(MTL_SYSTEM_ITEMS.Container_Item_Flag) = ''Y'''
                                );

                        if L_Success then
                                P_Container_Item_Id :=
                                        FND_FLEX_KEYVAL.Combination_Id;

                        else
                                P_Container_Item_Id := NULL;
                        end if;

                        If P_Container_Item_Id is NULL then

                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER');
                                FND_MESSAGE.Set_Token('COLUMN',
                                        'CONTAINER_ITEM', FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                                Curr_Error);
                                RAISE Error;
                        END IF;

                else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_CONCAT_SEG_ERROR');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                end if;

        ELSE
                Manage_Error_Code('IN', 'APP-00C03', Curr_Error);
                RAISE Error;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_CONTAINER');
                IF (P_Container_Item_Id IS NOT NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                'CONTAINER_ITEM_ID', FALSE);
                ELSIF ((P_Container_Item_Id IS NULL) AND
                       (P_Container_Item IS NOT NULL)) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                'CONTAINER_ITEM', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN',
                                'CONTAINER_ITEM_SEGMENT1 - 20', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43014', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_CONTAINERS');
                Manage_Error_Code('IN', 'APP-43055', Curr_Error);
                RAISE Error;

END Validate_Containers;


PROCEDURE Validate_Commodity_Code(
        P_Commodity_Code_Id             IN OUT  NOCOPY Number,
        P_Commodity_Code                IN      Varchar2        DEFAULT NULL
        )       IS

Temp_Commodity_Code_Id  Number := NULL;
Temp_Inactive_Date      Date   := NULL;

BEGIN

        IF (P_Commodity_Code_Id IS NOT NULL) THEN

                SELECT  Commodity_Code_Id, Inactive_Date
                INTO    Temp_Commodity_Code_Id, Temp_Inactive_Date
                FROM    MTL_COMMODITY_CODES MCC
                WHERE   MCC.Commodity_Code_Id = P_Commodity_Code_Id;

                IF ((SQL%FOUND) AND ((Temp_Inactive_Date IS NOT NULL)
                                     AND (Temp_Inactive_Date <= SYSDATE))) THEN

                        FND_MESSAGE.Set_Name('INV',
                                        'INV_INACTIVE_COMMODITY_CODE');
                        FND_MESSAGE.Set_Token('COLUMN',
                                'COMMODITY_CODE_ID', FALSE);
                        Manage_Error_Code('IN', 'APP-43015', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Commodity_Code_Id := Temp_Commodity_Code_Id;
                        RETURN;

                END IF;

        ELSIF ((P_Commodity_Code_Id IS NULL) AND
                (P_Commodity_Code IS NOT NULL)) THEN

                SELECT  Commodity_Code_Id, Inactive_Date
                INTO    Temp_Commodity_Code_Id, Temp_Inactive_Date
                FROM    MTL_COMMODITY_CODES MCC
                WHERE   MCC.Commodity_Code = P_Commodity_Code;

                IF ((SQL%FOUND) AND
                    ((Temp_Inactive_Date IS NOT NULL) AND
                     (Temp_Inactive_Date <= SYSDATE))) THEN

                        FND_MESSAGE.Set_Name('INV',
                                'INV_INACTIVE_COMMODITY_CODE');
                        FND_MESSAGE.Set_Token('COLUMN',
                                'COMMODITY_CODE', FALSE);
                        Manage_Error_Code('IN', 'APP-43015', Curr_Error);
                        RAISE Error;

                ELSE
                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Commodity_Code_Id := Temp_Commodity_Code_Id;
                        RETURN;

                END IF;

        ELSE
                FND_MESSAGE.Set_Name('INV', 'INV_NO_COMMODITY_CODE');
                Manage_Error_Code('IN', 'APP-43016', Curr_Error);
                RAISE Error;
        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_COMMODITY_CODE');
                IF (P_Commodity_Code_Id IS NOT NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                'COMMODITY_CODE_ID', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN',
                                'COMMODITY_CODE', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43017', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_COMMODITY_CODES');
                Manage_Error_Code('IN', 'APP-43018', Curr_Error);
                RAISE Error;

END Validate_Commodity_Code;


PROCEDURE Validate_Model(
        P_Model_Customer_Item_Id        IN OUT  NOCOPY Number,
        P_Model_Customer_Item           IN      Varchar2        DEFAULT NULL,
        P_Customer_Id                   IN      Number  DEFAULT NULL,
        P_Address_Id                    IN      Number  DEFAULT NULL,
        P_Customer_Category_Code        IN      Varchar2        DEFAULT NULL,
        P_Item_Definition_Level         IN      Varchar2        DEFAULT NULL,
        P_Customer_Item_Number          IN      Varchar2        DEFAULT NULL
        )       IS

Temp_Model_Customer_Item_Id     Number := NULL;
Temp_Item_Definition_Level      Varchar(1) := NULL;
Temp_Inactive_Flag              Varchar(1) := NULL;

BEGIN

        IF ((P_Customer_Id IS NULL) AND
            ((P_Address_Id IS NULL) OR
             (P_Customer_Category_Code IS NULL)) OR
            (P_Item_Definition_Level IS NULL) OR
            (P_Customer_Item_Number IS NULL)) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_NO_MODEL_CI_INFORMATION');
                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;
        ELSE

                IF (P_Model_Customer_Item_Id IS NOT NULL) THEN
        /* Bug 3849821 Select Customer_Item_Id of Model Ct Item entered in the Interface table */

                        SELECT  Customer_Item_Id,
                                Item_Definition_Level, Inactive_Flag
                        INTO    Temp_Model_Customer_Item_Id,
                                Temp_Item_Definition_Level, Temp_Inactive_Flag
                        FROM    MTL_CUSTOMER_ITEMS MCI
                        WHERE   MCI.Customer_Item_Id =
                                        P_Model_Customer_Item_Id
                        AND     MCI.Customer_Id =
                                        P_Customer_Id;

                        IF ((SQL%FOUND) AND (Temp_Inactive_Flag = 'Y')) THEN

                                FND_MESSAGE.Set_Name('INV',
                                                'INV_INACTIVE_MODEL_CI');
                                FND_MESSAGE.Set_Token('COLUMN',
                                                'MODEL_CUSTOMER_ITEM_ID',
                                                FALSE);
                                Manage_Error_Code('IN', 'APP-43019',
                                                Curr_Error);
                                RAISE Error;

                        ELSIF ((SQL%FOUND) AND (Temp_Inactive_Flag = 'N') AND
                               (Temp_Item_Definition_Level <=
                                        P_Item_Definition_Level)) THEN

                                Manage_Error_Code('IN', 'APP-00000',
                                                Curr_Error);
                                P_Model_Customer_Item_Id :=
                                                Temp_Model_Customer_Item_Id;
                                RETURN;

                        ELSE
                                FND_MESSAGE.Set_Name('INV',
                                                'INV_INV_MODEL_DEF_LVL');
                                FND_MESSAGE.Set_Token('COLUMN',
                                                'MODEL_CUSTOMER_ITEM_ID',
                                                FALSE);
                                Manage_Error_Code('IN', 'APP-43050',
                                                Curr_Error);
                                RAISE Error;
                        END IF;

                ELSIF ((P_Model_Customer_Item_Id IS NULL) AND
                       (P_Model_Customer_Item IS NOT NULL)) THEN
                --Bug:3849821
                        SELECT  Customer_Item_Id,
                                Item_Definition_Level, Inactive_Flag
                        INTO    Temp_Model_Customer_Item_Id,
                                Temp_Item_Definition_Level, Temp_Inactive_Flag
                        FROM    MTL_CUSTOMER_ITEMS MCI
                        WHERE   MCI.Customer_Item_Number =
                                        P_Model_Customer_Item
                        AND     MCI.Customer_Id = P_Customer_Id
                        AND     MCI.Customer_Category_Code =
                                        P_Customer_Category_Code
                        OR      MCI.Address_Id = P_Address_Id;

                        IF ((SQL%FOUND) AND (Temp_Inactive_Flag = 'Y')) THEN

                                FND_MESSAGE.Set_Name('INV',
                                                'INV_INACTIVE_MODEL_CI');
                                FND_MESSAGE.Set_Token('COLUMN',
                                                'MODEL_CUSTOMER_ITEM', FALSE);
                                Manage_Error_Code('IN', 'APP-43019',
                                                Curr_Error);
                                RAISE Error;

                        ELSIF ((SQL%FOUND) AND (Temp_Inactive_Flag = 'N') AND
                               (Temp_Item_Definition_Level <=
                                        P_Item_Definition_Level)) THEN

                                Manage_Error_Code('IN', 'APP-00000',
                                                Curr_Error);
                                P_Model_Customer_Item_Id :=
                                                Temp_Model_Customer_Item_Id;
                                RETURN;
                        ELSE

                                FND_MESSAGE.Set_Name('INV',
                                                'INV_INV_MODEL_DEF_LVL');
                                FND_MESSAGE.Set_Token('COLUMN',
                                                'MODEL_CUSTOMER_ITEM', FALSE);
                                Manage_Error_Code('IN', 'APP-43050',
                                                Curr_Error);
                                RAISE Error;

                        END IF;

                ELSE

                        FND_MESSAGE.Set_Name('INV',
                                        'INV_NO_MODEL_CI_INFORMATION');
                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        RETURN;

                END IF;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_MODEL_CI');
                IF (P_Model_Customer_Item_Id IS NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                        'MODEL_CUSTOMER_ITEM_ID', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN',
                                        'MODEL_CUSTOMER_ITEM', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43020', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_MODELS');
                Manage_Error_Code('IN', 'APP-43021', Curr_Error);
                RAISE Error;

END Validate_Model;


PROCEDURE Validate_Demand_Tolerance     (       P_Demand_Tolerance      IN      Number  DEFAULT NULL    )       IS

BEGIN

        IF ((P_Demand_Tolerance >= 999.99) OR (P_Demand_Tolerance <= 0)) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_TOLERANCE_OUT_RANGE');
                Manage_Error_Code('IN', 'APP-43022', Curr_Error);
                RAISE Error;

        ELSE

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;

        END IF;

END Validate_Demand_Tolerance;


PROCEDURE Validate_Fill_Percentage      (       P_Min_Fill_Percentage   IN      Number  DEFAULT NULL    )       IS

BEGIN

        IF ((P_Min_Fill_Percentage > 100) OR (P_Min_Fill_Percentage < 0)) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_FILL_PERCENT_OUT_RANGE');
                Manage_Error_Code('IN', 'APP-43023', Curr_Error);
                RAISE Error;

        ELSE

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;

        END IF;

END Validate_Fill_Percentage;


PROCEDURE Validate_Departure_Plan_Flags (
                P_Dep_Plan_Required_Flag        IN OUT  NOCOPY Varchar2,
                P_Dep_Plan_Prior_Bld_Flag       IN OUT  NOCOPY Varchar2
        )       IS

BEGIN

        IF (P_Dep_Plan_Required_Flag IS NULL) THEN
               P_Dep_Plan_Required_Flag:= '2';
        END IF;

        IF (P_Dep_Plan_Prior_Bld_Flag  IS NULL) THEN
               P_Dep_Plan_Prior_Bld_Flag:= '2';
        END IF;

        IF NOT (((P_Dep_Plan_Required_Flag = '1') OR
                 (P_Dep_Plan_Required_Flag = '2') OR
                 (P_Dep_Plan_Required_Flag IS NULL)) AND
                ((P_Dep_Plan_Prior_Bld_Flag = '1') OR
                 (P_Dep_Plan_Prior_Bld_Flag = '2') OR
                 (P_Dep_Plan_Prior_Bld_Flag IS NULL))) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INV_DEP_PLAN_FLAG');
                FND_MESSAGE.Set_Token('RULE',
                        'Departure Planning Flags <> 1, 2, or NULL', FALSE);
                Manage_Error_Code('IN', 'APP-43024', Curr_Error);
                RAISE Error;

        ELSIF ((P_Dep_Plan_Required_Flag = '2') AND
               (P_Dep_Plan_Prior_Bld_Flag = '1')) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INV_DEP_PLAN_FLAG');
                FND_MESSAGE.Set_Token('RULE',
                        'Departure Planning Prior Build = 1, Departure Planning Required = 2', FALSE);
                Manage_Error_Code('IN', 'APP-43024', Curr_Error);
                RAISE Error;

        ELSIF ((P_Dep_Plan_Required_Flag IS NULL) AND
               (P_Dep_Plan_Prior_Bld_Flag = '1')) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INV_DEP_PLAN_FLAG');
                FND_MESSAGE.Set_Token('RULE',
                        'Departure Planning Prior Build = 1, Departure Planning Required = NULL', FALSE);
                Manage_Error_Code('IN', 'APP-43024', Curr_Error);
                RAISE Error;

        ELSIF ((P_Dep_Plan_Required_Flag = '1') AND
               (P_Dep_Plan_Prior_Bld_Flag IS NULL)) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INV_DEP_PLAN_FLAG');
                FND_MESSAGE.Set_Token('RULE',
                        'Departure Planning Prior Build = NULL, Departure Planning Required = 1', FALSE);
                Manage_Error_Code('IN', 'APP-43024', Curr_Error);
                RAISE Error;

        ELSIF ((P_Dep_Plan_Required_Flag = '2') AND
               (P_Dep_Plan_Prior_Bld_Flag IS NULL)) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INV_DEP_PLAN_FLAG');
                FND_MESSAGE.Set_Token('RULE',
                        'Departure Planning Prior Build = NULL, Departure Planning Required = 2', FALSE);
                Manage_Error_Code('IN', 'APP-43024', Curr_Error);
                RAISE Error;

        ELSIF ((P_Dep_Plan_Required_Flag IS NULL) AND
               (P_Dep_Plan_Prior_Bld_Flag = '2')) THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INV_DEP_PLAN_FLAG');
                FND_MESSAGE.Set_Token('RULE',
                        'Departure Planning Prior Build = 2, Departure Planning Required = NULL', FALSE);
                Manage_Error_Code('IN', 'APP-43024', Curr_Error);
                RAISE Error;

        ELSIF ((P_Dep_Plan_Required_Flag IS NULL) AND
               (P_Dep_Plan_Prior_Bld_Flag IS NULL)) THEN

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;

        ELSE

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);

                IF (P_Dep_Plan_Prior_Bld_Flag = '1') THEN

                        P_Dep_Plan_Prior_Bld_Flag := 'Y';

                ELSE

                        P_Dep_Plan_Prior_Bld_Flag := 'N';

                END IF;

                IF (P_Dep_Plan_Required_Flag = '1') THEN

                        P_Dep_Plan_Required_Flag := 'Y';

                ELSE

                        P_Dep_Plan_Required_Flag := 'N';
                END IF;

        END IF;

END Validate_Departure_Plan_Flags;


/*===========================================================================+
 +===========================================================================*/
/* These procedures are specific to the Customer Item XRefs Open Interface.  */
/*===========================================================================+
 +===========================================================================*/

PROCEDURE Load_Cust_Item_Xrefs(ERRBUF OUT NOCOPY VARCHAR2,
                  RETCODE OUT NOCOPY VARCHAR2,
                  ARGUMENT1 IN VARCHAR2,
                  ARGUMENT2 IN VARCHAR2) IS

        L_Retcode Number;
        CONC_STATUS BOOLEAN;

    --3537282 : Gather stats before running
    l_schema          VARCHAR2(30);
    l_status          VARCHAR2(1);
    l_industry        VARCHAR2(1);
    l_records         NUMBER(10);

BEGIN

   --Start 3537282 : Gather stats before running
   IF fnd_global.conc_program_id <> -1 THEN
      SELECT count(*) INTO l_records
      FROM   mtl_ci_xrefs_interface
      WHERE  process_flag = 1;

   -- Bug 6983407 Collect statistics only if the no. of records is bigger than the profile
   -- option threshold
       IF l_records > nvl(fnd_profile.value('EGO_GATHER_STATS'),100) AND FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema)   THEN
         IF l_schema IS NOT NULL    THEN
            FND_STATS.GATHER_TABLE_STATS(l_schema, 'MTL_CI_XREFS_INTERFACE');
          END IF;
       END IF;
   END IF;
   --End 3537282 : Gather stats before running


        L_Retcode := Load_Cust_Item_Xrefs_Iface(argument1,
                                        argument2);

        if L_Retcode = 1 then
                RETCODE := 'Success';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);


        elsif L_Retcode = 3 then
                RETCODE := 'Warning';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);

        else
                RETCODE := 'Error';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        end if;

END Load_Cust_Item_Xrefs;


FUNCTION Load_Cust_Item_XRefs_Iface(
                Abort_On_Error  IN      Varchar2        DEFAULT 'No',
                Delete_Record   IN      Varchar2        DEFAULT 'Yes'
        )  RETURN Number IS

        L_Success Number := 1;

        CURSOR  CI_XRefs_Cur IS
        SELECT  Rowid Row_Id,
                        Process_Mode,
                        Customer_Name,
                        Customer_Number,
                        Customer_Id,
                        Customer_Category_Code,
                        Customer_Category,
                        Address1,
                        Address2,
                        Address3,
                        Address4,
                        City,
                        State,
                        County,
                        Country,
                        Postal_Code,
                        Address_Id,
                        Customer_Item_Number,
                        Item_Definition_Level_Desc,
                        Item_Definition_Level,
                        Customer_Item_Id,
                        Master_Organization_Name,
                        Master_Organization_Code,
                        Master_Organization_Id,
                        Inventory_Item_Segment1,
                        Inventory_Item_Segment2,
                        Inventory_Item_Segment3,
                        Inventory_Item_Segment4,
                        Inventory_Item_Segment5,
                        Inventory_Item_Segment6,
                        Inventory_Item_Segment7,
                        Inventory_Item_Segment8,
                        Inventory_Item_Segment9,
                        Inventory_Item_Segment10,
                        Inventory_Item_Segment11,
                        Inventory_Item_Segment12,
                        Inventory_Item_Segment13,
                        Inventory_Item_Segment14,
                        Inventory_Item_Segment15,
                        Inventory_Item_Segment16,
                        Inventory_Item_Segment17,
                        Inventory_Item_Segment18,
                        Inventory_Item_Segment19,
                        Inventory_Item_Segment20,
                        Inventory_Item,
                        Inventory_Item_Id,
                        Preference_Number,
                        Inactive_Flag,
                        Attribute_Category,
                        Attribute1,
                        Attribute2,
                        Attribute3,
                        Attribute4,
                        Attribute5,
                        Attribute6,
                        Attribute7,
                        Attribute8,
                        Attribute9,
                        Attribute10,
                        Attribute11,
                        Attribute12,
                        Attribute13,
                        Attribute14,
                        Attribute15,
                        Last_Update_Date,
                        Last_Updated_By,
                        Creation_Date,
                        Created_By,
                        Last_Update_Login,
                        Request_Id,
                        Program_Application_Id,
                        Program_Id,
                        Program_Update_Date
        FROM            MTL_CI_XREFS_INTERFACE
        WHERE           Process_Flag = 1
        AND             Process_Mode = 1
        OR              Process_Mode = 3
        AND             UPPER(Transaction_Type) = 'CREATE'
        FOR UPDATE NOWAIT;

        Recinfo2 CI_XRefs_Cur%ROWTYPE;

        Error_Number    Number  := NULL;
        Error_Message   Varchar2(2000) := NULL;
        Error_Counter   Number  := 0;
        Curr_Error      Varchar2(9) := 'APP-00000';

BEGIN

        OPEN CI_XRefs_Cur;

        While (UPPER(Abort_On_Error) <> 'Y' or
                Error_Counter <= 0) LOOP

                FETCH CI_XRefs_Cur INTO Recinfo2;

                EXIT WHEN CI_XRefs_Cur%NOTFOUND;

                BEGIN

                        IF (Recinfo2.Process_Mode = 1) THEN

                           Validate_CI_XRefs(Recinfo2.Row_Id,
                                Recinfo2.Process_Mode,
                                Recinfo2.Customer_Name,
                                Recinfo2.Customer_Number,
                                Recinfo2.Customer_Id,
                                Recinfo2.Customer_Category_Code,
                                Recinfo2.Customer_Category,
                                Recinfo2.Address1, Recinfo2.Address2,
                                Recinfo2.Address3, Recinfo2.Address4,
                                Recinfo2.City, Recinfo2.State,
                                Recinfo2.County, Recinfo2.Country,
                                Recinfo2.Postal_Code, Recinfo2.Address_Id,
                                Recinfo2.Customer_Item_Number,
                                Recinfo2.Item_Definition_Level_Desc,
                                Recinfo2.Item_Definition_Level,
                                Recinfo2.Customer_Item_Id,
                                Recinfo2.Master_Organization_Name,
                                Recinfo2.Master_Organization_Code,
                                Recinfo2.Master_Organization_Id,
                                Recinfo2.Inventory_Item_Segment1,
                                Recinfo2.Inventory_Item_Segment2,
                                Recinfo2.Inventory_Item_Segment3,
                                Recinfo2.Inventory_Item_Segment4,
                                Recinfo2.Inventory_Item_Segment5,
                                Recinfo2.Inventory_Item_Segment6,
                                Recinfo2.Inventory_Item_Segment7,
                                Recinfo2.Inventory_Item_Segment8,
                                Recinfo2.Inventory_Item_Segment9,
                                Recinfo2.Inventory_Item_Segment10,
                                Recinfo2.Inventory_Item_Segment11,
                                Recinfo2.Inventory_Item_Segment12,
                                Recinfo2.Inventory_Item_Segment13,
                                Recinfo2.Inventory_Item_Segment14,
                                Recinfo2.Inventory_Item_Segment15,
                                Recinfo2.Inventory_Item_Segment16,
                                Recinfo2.Inventory_Item_Segment17,
                                Recinfo2.Inventory_Item_Segment18,
                                Recinfo2.Inventory_Item_Segment19,
                                Recinfo2.Inventory_Item_Segment20,
                                Recinfo2.Inventory_Item,
                                Recinfo2.Inventory_Item_Id,
                                Recinfo2.Preference_Number,
                                Recinfo2.Inactive_Flag,
                                Recinfo2.Attribute_Category,
                                Recinfo2.Attribute1, Recinfo2.Attribute2,
                                Recinfo2.Attribute3, Recinfo2.Attribute4,
                                Recinfo2.Attribute5, Recinfo2.Attribute6,
                                Recinfo2.Attribute7, Recinfo2.Attribute8,
                                Recinfo2.Attribute9, Recinfo2.Attribute10,
                                Recinfo2.Attribute11, Recinfo2.Attribute12,
                                Recinfo2.Attribute13, Recinfo2.Attribute14,
                                Recinfo2.Attribute15,
                                Recinfo2.Last_Update_Date,
                                Recinfo2.Last_Updated_By,
                                Recinfo2.Creation_Date,
                                Recinfo2.Created_By,
                                Recinfo2.Last_Update_Login,
                                nvl(Recinfo2.Request_Id, fnd_global.conc_request_id),
                                nvl(Recinfo2.Program_Application_Id, fnd_global.prog_appl_id),
                                nvl(Recinfo2.Program_Id, fnd_global.conc_program_id),
                                nvl(Recinfo2.Program_Update_Date, sysdate),
                                Delete_Record);
/*
                                if L_Success = 1 then
                                        COMMIT;
                                end if;
*/

                        ELSIF (Recinfo2.Process_Mode = 3) THEN

                           Delete_Row('X', Delete_Record, Recinfo2.Row_Id);

/*
                           if L_Success = 1 then
                                COMMIT;
                           end if;
*/

                        ELSE
                           NULL;
                        END IF;

                EXCEPTION

                WHEN Error THEN

                        L_Success := 3;

                        Error_Counter := Error_Counter + 1;
                        FND_MESSAGE.Set_Token('TABLE',
                                'MTL_CI_XREFS_INTERFACE', FALSE);
                        Error_Message := FND_MESSAGE.Get;
                        Manage_Error_Code('OUT', NULL, Curr_Error);

                        UPDATE  MTL_CI_XREFS_INTERFACE MCIXI
                        SET     MCIXI.Error_Code = Curr_Error,
                                MCIXI.Error_Explanation = substrb(Error_Message,1,235),
                                MCIXI.Process_Mode = 2
                        WHERE   MCIXI.Rowid = Recinfo2.Row_Id;
/*
                        commit;
*/
                WHEN OTHERS THEN

                        L_Success := 2;

                        Error_Counter   :=      Error_Counter + 1;
                        Error_Number    :=      SQLCODE;
                        Error_Message   :=      SUBSTRB(SQLERRM, 1, 512);

                        UPDATE  MTL_CI_XREFS_INTERFACE MCIXI
                        SET     MCIXI.Error_Code = TO_CHAR(Error_Number),
                                MCIXI.Error_Explanation = substrb(Error_Message,1,235),
                                MCIXI.Process_Mode = 2
                        WHERE   MCIXI.Rowid = Recinfo2.Row_Id;
/*
                        commit;
*/
                END;

        END LOOP;

        CLOSE CI_XRefs_Cur;

        IF (Error_Counter > 0) THEN

                L_Success := 3;

                FND_MESSAGE.Set_Name('INV', 'INV_CI_OPEN_INT_WARNING');
                FND_MESSAGE.Set_Token('TABLE',
                                'MTL_CI_XREFS_INTERFACE', FALSE);
                FND_MESSAGE.Set_Token('ERROR_COUNT', Error_Counter, FALSE);
                Error_Message   :=      FND_MESSAGE.Get;
                --DBMS_OUTPUT.Put_Line(Error_Message);
        END IF;

        COMMIT;

        RETURN L_Success;

EXCEPTION

        WHEN Error THEN

                L_Success := 3;

                Error_Counter := Error_Counter + 1;
                FND_MESSAGE.Set_Token('TABLE',
                                'MTL_CI_XREFS_INTERFACE', FALSE);
                Error_Message := FND_MESSAGE.Get;
                Manage_Error_Code('OUT', NULL, Curr_Error);

                UPDATE  MTL_CI_XREFS_INTERFACE MCIXI
                SET     MCIXI.Error_Code = Curr_Error,
                        MCIXI.Error_Explanation = substrb(Error_Message,1,235),
                        MCIXI.Process_Mode = 2
                WHERE   MCIXI.Rowid = Recinfo2.Row_Id;

                commit;

                Return L_Success;

        WHEN OTHERS THEN

                L_Success := 2;

                Error_Counter := Error_Counter + 1;
                Error_Number  := SQLCODE;
                Error_Message := SUBSTRB(SQLERRM, 1, 512);


		/* Fix for bug 5263099 - Added the below code to handle the scenario
		   where Cursor CI_XRefs_Cur fails to open because the rows in
 		   MTL_CI_XREFS_INTERFACE are already locked by some other session.
		   It leads to "ORA-00054-resource busy and acquire with NOWAIT specified" error.
		   So we check for this error condition SQLCODE= -54.
		   Manage_Error_Code will set the Current_Error_Code to the corresponding
		   error msg which shall then be shown in the conc prog log file.
		*/
		If SQLCODE= -54 Then
			Manage_Error_Code('IN',substrb(Error_Message,1,235), Curr_Error);
		End If;

                UPDATE  MTL_CI_XREFS_INTERFACE MCIXI
                SET     MCIXI.Error_Code = TO_CHAR(Error_Number),
                        MCIXI.Error_Explanation = substrb(Error_Message,1,235),
                        MCIXI.Process_Mode = 2
                WHERE   MCIXI.Rowid = Recinfo2.Row_Id;

                commit;

                Return L_Success;

END Load_Cust_Item_XRefs_Iface;


PROCEDURE Validate_CI_XRefs(
                                                Row_Id                          IN OUT  NOCOPY Varchar2,
                                                Process_Mode                    IN OUT  NOCOPY Varchar2,
                                                Customer_Name                   IN OUT  NOCOPY Varchar2,
                                                Customer_Number                 IN OUT  NOCOPY Varchar2,
                                                Customer_Id                     IN OUT  NOCOPY Number,
                                                Customer_Category_Code          IN OUT  NOCOPY Varchar2,
                                                Customer_Category               IN OUT  NOCOPY Varchar2,
                                                Address1                        IN OUT  NOCOPY Varchar2,
                                                Address2                        IN OUT  NOCOPY Varchar2,
                                                Address3                        IN OUT  NOCOPY Varchar2,
                                                Address4                        IN OUT  NOCOPY Varchar2,
                                                City                            IN OUT  NOCOPY Varchar2,
                                                State                           IN OUT  NOCOPY Varchar2,
                                                County                          IN OUT  NOCOPY Varchar2,
                                                Country                         IN OUT  NOCOPY Varchar2,
                                                Postal_Code                     IN OUT  NOCOPY Varchar2,
                                                Address_Id                      IN OUT  NOCOPY Number,
                                                Customer_Item_Number            IN OUT  NOCOPY Varchar2,
                                                Item_Definition_Level_Desc      IN OUT  NOCOPY Varchar2,
                                                Item_Definition_Level           IN OUT  NOCOPY Varchar2,
                                                Customer_Item_Id                IN OUT  NOCOPY Number,
                                                Master_Organization_Name        IN OUT  NOCOPY Varchar2,
                                                Master_Organization_Code        IN OUT  NOCOPY Varchar2,
                                                Master_Organization_Id          IN OUT  NOCOPY Number,
                                                Inventory_Item_Segment1         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment2         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment3         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment4         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment5         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment6         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment7         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment8         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment9         IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment10        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment11        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment12        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment13        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment14        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment15        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment16        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment17        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment18        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment19        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Segment20        IN OUT  NOCOPY Varchar2,
                                                Inventory_Item                  IN OUT  NOCOPY Varchar2,
                                                Inventory_Item_Id               IN OUT  NOCOPY Number,
                                                Preference_Number               IN OUT  NOCOPY Number,
                                                Inactive_Flag                   IN OUT  NOCOPY Varchar2,
                                                Attribute_Category              IN OUT  NOCOPY Varchar2,
                                                Attribute1                      IN OUT  NOCOPY Varchar2,
                                                Attribute2                      IN OUT  NOCOPY Varchar2,
                                                Attribute3                      IN OUT  NOCOPY Varchar2,
                                                Attribute4                      IN OUT  NOCOPY Varchar2,
                                                Attribute5                      IN OUT  NOCOPY Varchar2,
                                                Attribute6                      IN OUT  NOCOPY Varchar2,
                                                Attribute7                      IN OUT  NOCOPY Varchar2,
                                                Attribute8                      IN OUT  NOCOPY Varchar2,
                                                Attribute9                      IN OUT  NOCOPY Varchar2,
                                                Attribute10                     IN OUT  NOCOPY Varchar2,
                                                Attribute11                     IN OUT  NOCOPY Varchar2,
                                                Attribute12                     IN OUT  NOCOPY Varchar2,
                                                Attribute13                     IN OUT  NOCOPY Varchar2,
                                                Attribute14                     IN OUT  NOCOPY Varchar2,
                                                Attribute15                     IN OUT  NOCOPY Varchar2,
                                                Last_Update_Date                IN OUT  NOCOPY Date,
                                                Last_Updated_By                 IN OUT  NOCOPY Number,
                                                Creation_Date                   IN OUT  NOCOPY Date,
                                                Created_By                      IN OUT  NOCOPY Number,
                                                Last_Update_Login               IN OUT  NOCOPY Number,
                                                Request_Id                      IN      Number,
                                                Program_Application_Id          IN      Number,
                                                Program_Id                      IN      Number,
                                                Program_Update_Date             IN      Date,
                                                Delete_Record                   IN      Varchar2        DEFAULT NULL    )       IS

BEGIN

        Validate_Cust_Item(Customer_Item_Id, Customer_Item_Number, Item_Definition_Level, Item_Definition_Level_Desc, Customer_Id,
         Customer_Number, Customer_Name, Customer_Category_Code, Customer_Category, Address_Id, Address1, Address2, Address3,
         Address4, City, State, County, Country, Postal_Code);

        Validate_Master_Organization(Master_Organization_Id, Master_Organization_Code, Master_Organization_Name);

        Validate_Inventory_Item(
             Inventory_Item_Id,
             Inventory_Item,
             Inventory_Item_Segment1,
             Inventory_Item_Segment2,
             Inventory_Item_Segment3,
             Inventory_Item_Segment4,
             Inventory_Item_Segment5,
             Inventory_Item_Segment6,
             Inventory_Item_Segment7,
             Inventory_Item_Segment8,
             Inventory_Item_Segment9,
             Inventory_Item_Segment10,
             Inventory_Item_Segment11,
             Inventory_Item_Segment12,
             Inventory_Item_Segment13,
             Inventory_Item_Segment14,
             Inventory_Item_Segment15,
             Inventory_Item_Segment16,
             Inventory_Item_Segment17,
             Inventory_Item_Segment18,
             Inventory_Item_Segment19,
             Inventory_Item_Segment20,
             Master_Organization_Id);

        Validate_Inactive_Flag(Inactive_Flag);

        Check_Required_Columns(NULL, NULL, NULL, NULL, NULL, NULL, Inactive_Flag, Last_Updated_By, Last_Update_Date, Created_By,
         Creation_Date, Customer_Item_Id, Inventory_Item_Id, Master_Organization_Id, Preference_Number);

        Check_Uniqueness(NULL, NULL, NULL, NULL, NULL, NULL, Customer_Item_Id, Inventory_Item_Id, Master_Organization_Id, Preference_Number);

        Validate_Concurrent_Program(Request_Id, Program_Application_Id, Program_Id, Program_Update_Date);

        Insert_Row(
             NULL,
             Last_Update_Date,
             Last_Updated_By,
             Creation_Date,
             Created_By,
             Last_Update_Login,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             Inactive_Flag,
             Attribute_Category,
             Attribute1,
             Attribute2,
             Attribute3,
             Attribute4,
             Attribute5,
             Attribute6,
             Attribute7,
             Attribute8,
             Attribute9,
             Attribute10,
             Attribute11,
             Attribute12,
             Attribute13,
             Attribute14,
             Attribute15,
             NULL,
             NULL,
             Request_Id,
             Program_Application_Id,
             Program_Id,
             Program_Update_Date,
             Customer_Item_Id,
             Inventory_Item_Id,
             Master_Organization_Id,
             Preference_Number);

        Delete_Row('X', Delete_Record, Row_Id);

END Validate_CI_XRefs;


PROCEDURE Validate_Cust_Item    (       P_Customer_Item_Id                      IN OUT         NOCOPY  Number,
                                                P_Customer_Item_Number          IN              Varchar2        DEFAULT NULL,
                                                P_Item_Definition_Level         IN              Varchar2        DEFAULT NULL,
                                                P_Item_Definition_Level_Desc    IN              Varchar2        DEFAULT NULL,
                                                P_Customer_Id                   IN              Number          DEFAULT NULL,
                                                P_Customer_Number               IN              Varchar2        DEFAULT NULL,
                                                P_Customer_Name                 IN              Varchar2        DEFAULT NULL,
                                                P_Customer_Category_Code        IN              Varchar2        DEFAULT NULL,
                                                P_Customer_Category             IN              Varchar2        DEFAULT NULL,
                                                P_Address_Id                    IN              Number          DEFAULT NULL,
                                                P_Address1                      IN              Varchar2        DEFAULT NULL,
                                                P_Address2                      IN              Varchar2        DEFAULT NULL,
                                                P_Address3                      IN              Varchar2        DEFAULT NULL,
                                                P_Address4                      IN              Varchar2        DEFAULT NULL,
                                                P_City                          IN              Varchar2        DEFAULT NULL,
                                                P_State                         IN              Varchar2        DEFAULT NULL,
                                                P_County                        IN              Varchar2        DEFAULT NULL,
                                                P_Country                       IN              Varchar2        DEFAULT NULL,
                                                P_Postal_Code                   IN              Varchar2        DEFAULT NULL    )       IS

Temp_Customer_Item_Id           Number          :=      NULL;
Temp_Inactive_Flag              Varchar2(1)     :=      NULL;
V_Item_Definition_Level         Varchar2(1)     :=      P_Item_Definition_Level;
V_Item_Definition_Level_Desc    Varchar2(30)    :=      P_Item_Definition_Level_Desc;
V_Customer_Id                   Number          :=      P_Customer_Id;
V_Customer_Number               Varchar2(50)    :=      P_Customer_Number;
V_Customer_Name                 Varchar2(50)    :=      P_Customer_Name;
V_Customer_Category_Code        Varchar2(30)    :=      P_Customer_Category_Code;
V_Customer_Category             Varchar2(80)    :=      P_Customer_Category;
V_Address_Id                    Number          :=      P_Address_Id;
V_Address1                      Varchar2(240)   :=      P_Address1;
V_Address2                      Varchar2(240)   :=      P_Address2;
V_Address3                      Varchar2(240)   :=      P_Address3;
V_Address4                      Varchar2(240)   :=      P_Address4;
V_City                          Varchar2(50)    :=      P_City;
V_State                         Varchar2(50)    :=      P_State;
V_County                        Varchar2(50)    :=      P_County;
V_Country                       Varchar2(50)    :=      P_Country;
V_Postal_Code                   Varchar2(30)    :=      P_Postal_Code;


BEGIN

        IF (P_Customer_Item_Id IS NOT NULL) THEN

                SELECT  Customer_Item_Id, Inactive_Flag
                INTO            Temp_Customer_Item_Id, Temp_Inactive_Flag
                FROM            MTL_CUSTOMER_ITEMS MCI
                WHERE           MCI.Customer_Item_Id    =       P_Customer_Item_Id;


                IF (SQL%FOUND) THEN

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Customer_Item_Id      :=      Temp_Customer_Item_Id;
                        RETURN;

                END IF;

        ELSIF ((P_Customer_Item_Id IS NULL) AND (P_Customer_Item_Number IS NOT NULL)) THEN

                Validate_CI_Def_Level (V_Item_Definition_Level, V_Item_Definition_Level_Desc, V_Customer_Id,
                 V_Customer_Number, V_Customer_Name, V_Customer_Category_Code, V_Customer_Category,
                 V_Address_Id, V_Address1, V_Address2, V_Address3, V_Address4, V_City, V_State, V_County, V_Country, V_Postal_Code);

                SELECT  Customer_Item_Id, Inactive_Flag
                INTO            Temp_Customer_Item_Id, Temp_Inactive_Flag
                FROM            MTL_CUSTOMER_ITEMS MCI
                WHERE           MCI.Item_Definition_Level                       =       NVL(P_Item_Definition_Level, V_Item_Definition_Level)
                AND             MCI.Customer_Id                                 =       NVL(P_Customer_Id, V_Customer_Id)
                AND             NVL(MCI.Customer_Category_Code, ' ')            =       NVL(NVL(P_Customer_Category_Code, V_Customer_Category_Code), ' ')
                AND             NVL(MCI.Address_Id, -99)                        =       NVL(NVL(P_Address_Id, V_Address_Id), -99)
                AND             MCI.Customer_Item_Number                        =       P_Customer_Item_Number;

                IF (SQL%FOUND) THEN

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Customer_Item_Id      :=      Temp_Customer_Item_Id;
                        RETURN;

                END IF;

        ELSE

                        FND_MESSAGE.Set_Name('INV', 'INV_MISSING_CI_INFO');
                        Manage_Error_Code('IN', 'APP-43051', Curr_Error);
                        RAISE Error;

        END IF;


EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_CI');
                IF (P_Customer_Item_Id IS NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_ITEM_ID', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_ITEM_NUMBER', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43052', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_CI');
                Manage_Error_Code('IN', 'APP-43053', Curr_Error);
                RAISE Error;

END Validate_Cust_Item;


PROCEDURE Validate_Master_Organization(
        P_Master_Organization_Id        IN OUT  NOCOPY Number,
        P_Master_Organization_Code      IN      Varchar2        DEFAULT NULL,
        P_Master_Organization_Name      IN      Varchar2        DEFAULT NULL
        )       IS

Temp_Master_Organization_Id     Number := NULL;
Temp_Date_From                  Date := NULL;
Temp_Date_To                    Date := NULL;

BEGIN

        IF (P_Master_Organization_Id IS NOT NULL) THEN

                SELECT  MP.Organization_Id,
                                 HROU.Date_From, HROU.Date_To
                INTO    Temp_Master_Organization_Id,
                        Temp_Date_From, Temp_Date_To
                FROM    HR_ORGANIZATION_UNITS HROU,
                        MTL_PARAMETERS MP
                WHERE   MP.Organization_Id =
                                P_Master_Organization_Id
                AND     HROU.Organization_Id =
                                MP.Organization_Id;

                IF ((SQL%FOUND) AND
                    (NOT (TRUNC(SYSDATE) BETWEEN
                        NVL(TRUNC((Temp_Date_From)),SYSDATE)
                           AND NVL(TRUNC((Temp_Date_To)), SYSDATE)))) THEN

                        FND_MESSAGE.Set_Name('INV',
                                'INV_INACTIVE_ORGANIZATION');
                        FND_MESSAGE.Set_Token('COLUMN',
                                'MASTER_ORGANIZATION_ID', FALSE);
                        Manage_Error_Code('IN', 'APP-43027', Curr_Error);
                        RAISE Error;
                ELSE
                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Master_Organization_Id :=
                                Temp_Master_Organization_Id;
                        RETURN;
                END IF;

        ELSIF ((P_Master_Organization_Id IS NULL)
                AND (P_Master_Organization_Code IS NOT NULL)) THEN

                SELECT  MP.Organization_Id, HROU.Date_From,
                        HROU.Date_To
                INTO    Temp_Master_Organization_Id, Temp_Date_From,
                        Temp_Date_To
                FROM    MTL_PARAMETERS MP,
                        HR_ORGANIZATION_UNITS HROU
                WHERE   MP.Organization_Code = P_Master_Organization_Code
                AND     HROU.Organization_Id = MP.Organization_id;

                IF ((SQL%FOUND) AND
                    (NOT (TRUNC(SYSDATE) BETWEEN
                        NVL(TRUNC((Temp_Date_From)),SYSDATE)
                        AND NVL(TRUNC((Temp_Date_To)), SYSDATE)))) THEN

                        FND_MESSAGE.Set_Name('INV',
                                'INV_INACTIVE_ORGANIZATION');
                        FND_MESSAGE.Set_Token('COLUMN',
                                'MASTER_ORGANIZATION_CODE', FALSE);
                        Manage_Error_Code('IN', 'APP-43027', Curr_Error);
                        RAISE Error;
                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Master_Organization_Id :=
                                Temp_Master_Organization_Id;
                        RETURN;
                END IF;
        ELSIF ((P_Master_Organization_Id IS NULL)
                AND (P_Master_Organization_Code IS NULL)
                AND (P_Master_Organization_Name IS NOT NULL)) THEN

                SELECT  MP.Organization_Id, HROU.Date_From,
                        HROU.Date_To
                INTO    Temp_Master_Organization_Id, Temp_Date_From,
                        Temp_Date_To
                FROM    MTL_PARAMETERS MP,
                        HR_ORGANIZATION_INFORMATION HROI,
                        HR_ORGANIZATION_UNITS HROU
                WHERE   HROU.Name = P_Master_Organization_Name
                AND     MP.Organization_Id = HROU.Organization_Id
                AND     HROI.Organization_Id = MP.Organization_Id
                AND     HROI.Org_Information_Context = 'CLASS'
                AND     HROI.Org_Information1 = 'INV'
                AND     HROI.Org_Information2 = 'Y';

                IF ((SQL%FOUND) AND
                        (NOT (TRUNC(SYSDATE) BETWEEN
                        NVL(TRUNC((Temp_Date_From)),SYSDATE)
                        AND NVL(TRUNC((Temp_Date_To)), SYSDATE)))) THEN

                        FND_MESSAGE.Set_Name('INV',
                                'INV_INACTIVE_ORGANIZATION');
                        FND_MESSAGE.Set_Token('COLUMN',
                                'MASTER_ORGANIZATION_NAME', FALSE);
                        Manage_Error_Code('IN', 'APP-43027', Curr_Error);
                        RAISE Error;
                ELSE
                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Master_Organization_Id :=
                                Temp_Master_Organization_Id;
                        RETURN;
                END IF;
        ELSE
                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ORGANIZATION');
                        FND_MESSAGE.Set_Token('COLUMN1',
                                'MASTER_ORGANIZATION_ID', FALSE);
                        FND_MESSAGE.Set_Token('COLUMN2',
                                'MASTER_ORGANIZATION_CODE', FALSE);
                        FND_MESSAGE.Set_Token('COLUMN3',
                                'MASTER_ORGANIZATION_NAME', FALSE);
                        Manage_Error_Code('IN', 'APP-43045', Curr_Error);
                        RAISE Error;
        END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_ORGANIZATION');
                IF (P_Master_Organization_Id IS NOT NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                'MASTER_ORGANIZATION_ID', FALSE);
                ELSIF ((P_Master_Organization_Id IS NULL)
                       AND (P_Master_Organization_Code IS NOT NULL)) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                'MASTER_ORGANIZATION_CODE', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN',
                                'MASTER_ORGANIZATION_NAME', FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43028', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_ORGANIZATIONS');
                Manage_Error_Code('IN', 'APP-43029', Curr_Error);
                RAISE Error;

END Validate_Master_Organization;


PROCEDURE Validate_Inventory_Item(
        P_Inventory_Item_Id             IN OUT  NOCOPY Number,
        P_Inventory_Item                IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment1       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment2       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment3       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment4       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment5       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment6       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment7       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment8       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment9       IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment10      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment11      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment12      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment13      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment14      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment15      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment16      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment17      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment18      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment19      IN      Varchar2        DEFAULT NULL,
        P_Inventory_Item_Segment20      IN      Varchar2        DEFAULT NULL,
        P_Master_Organization_Id        IN      Number          DEFAULT NULL
        )       IS

Now Varchar2(20) := TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS');
Temp_Inventory_Item_Id  Number := NULL;
Dummy_Inventory_Item_Id Number := NULL;

L_Segment_Array fnd_flex_ext.SegmentArray;
L_SegOrder_Array SegOrderArray;
L_TempSeg_Counter Number := 0;
L_Success Boolean;
L_Temp_Concat_Container Varchar2(2000);
L_FlexSeg_Counter Number := 0;

Cursor L_FlexSegOrder_Curr is
        SELECT segment_num from
        fnd_id_flex_segments
        where application_id = 401
        and id_flex_code = 'MSTK'
        and enabled_flag = 'Y'
        order by segment_num;

L_SegNumDummy Number;
L_SegNumIndex Number := 0;
L_Delimiter Varchar2(1) := NULL;
L_ConcatSegs Varchar2(2000) := NULL;
L_StructNum Number := NULL;

BEGIN

        IF (P_Inventory_Item_Id IS NOT NULL) THEN

                SELECT  Inventory_Item_Id
                INTO    Temp_Inventory_Item_Id
                FROM    MTL_SYSTEM_ITEMS MSI
                WHERE   MSI.Inventory_Item_Id = P_Inventory_Item_Id
                AND     MSI.Organization_Id = P_Master_Organization_Id
                AND     NVL(MSI.Approval_Status,'A') = 'A';--Added for 11.5.10 PLM

                IF (SQL%FOUND) THEN

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        P_Inventory_Item_Id := Temp_Inventory_Item_Id;
                        RETURN;

                END IF;

        ELSIF ((P_Inventory_Item_Id IS NULL) AND
               (P_Inventory_Item IS NOT NULL)) THEN

                BEGIN
                        SELECT ID_Flex_Num
                        INTO L_StructNum
                        FROM fnd_id_flex_structures
                        WHERE application_id = 401
                        AND id_flex_code = 'MSTK'
                        AND upper(enabled_flag) = 'Y';
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;

                   WHEN TOO_MANY_ROWS THEN
                        FND_MESSAGE.Set_Name('INV',
                                        'INV_MULT_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;
                END;

                L_Success := FND_FLEX_KEYVAL.Validate_Segs(
                                OPERATION       => 'FIND_COMBINATION',
                                APPL_SHORT_NAME => 'INV',
                                KEY_FLEX_CODE   => 'MSTK',
                                STRUCTURE_NUMBER=> L_StructNum,
                                CONCAT_SEGMENTS => P_Inventory_Item,
                                DATA_SET        => P_Master_Organization_Id
                        );

                if L_Success then
                        P_Inventory_Item_Id :=
                                FND_FLEX_KEYVAL.Combination_Id;

                else
                        P_Inventory_Item_Id := NULL;
                end if;

                If P_Inventory_Item_Id is NULL then

                        FND_MESSAGE.Set_Name('INV', 'INV_INVALID_INV_ITEM');
                        FND_MESSAGE.Set_Token('COLUMN',
                                        'INVENTORY_ITEM', FALSE);
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;
                END IF;

        ELSIF ((P_Inventory_Item_Id IS NULL) AND
               (P_Inventory_Item IS NULL)) THEN

                BEGIN
                        SELECT ID_Flex_Num
                        INTO L_StructNum
                        FROM fnd_id_flex_structures
                        WHERE application_id = 401
                        AND id_flex_code = 'MSTK'
                        AND upper(enabled_flag) = 'Y';
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.Set_Name('INV', 'INV_NO_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;

                   WHEN TOO_MANY_ROWS THEN
                        FND_MESSAGE.Set_Name('INV',
                                        'INV_MULT_ITEM_FLEX_STRUCT');
                        Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                        RAISE Error;
                END;

                OPEN L_FlexSegOrder_Curr;

                LOOP
                        FETCH L_FlexSegOrder_Curr into L_SegNumDummy;
                        EXIT WHEN L_FlexSegOrder_Curr%NOTFOUND;

                        L_FlexSeg_Counter := L_FlexSeg_Counter+1;
                        L_Segment_Array(L_FlexSeg_Counter) := NULL;
                        L_SegOrder_Array(L_FlexSeg_Counter) := L_SegNumDummy;
                END LOOP;

                CLOSE L_FlexSegOrder_Curr;

                if P_Inventory_Item_Segment1 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT1';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT1',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment1;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment2 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT2';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT2',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment2;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment3 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT3';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT3',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment3;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment4 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT4';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT4',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment4;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment5 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT5';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT5',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment5;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment6 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT6';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT6',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment6;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment7 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT7';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT7',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment7;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment8 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT8';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT8',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment8;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment9 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT9';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT9',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment9;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment10 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT10';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT10',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment10;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment11 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT11';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT11',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment11;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment12 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT12';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT12',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment12;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment13 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT13';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT13',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment13;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment14 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT14';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT14',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment14;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment15 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT15';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT15',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment15;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment16 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT16';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT16',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment16;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment17 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT17';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT17',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment17;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment18 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT18';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT18',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment18;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment19 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT19';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT19',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment19;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                if P_Inventory_Item_Segment20 IS NOT NULL THEN
                        L_TempSeg_Counter := L_TempSeg_Counter + 1;

                        BEGIN
                                select segment_num
                                into L_SegNumDummy
                                from fnd_id_flex_segments
                                where application_id = 401
                                and id_flex_code = 'MSTK'
                                and enabled_flag = 'Y'
                                and application_column_name = 'SEGMENT20';

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_ITEM_SEG');
                                FND_MESSAGE.Set_Token('SEGMENT',
                                        'SEGMENT20',
                                        FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                          WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_MULTIPLE_FLEX_SEG');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                        END;

                        L_SegNumIndex := 0;

                        for i in 1..L_FlexSeg_Counter loop

                                L_SegNumIndex := i;

                                EXIT WHEN L_SegOrder_Array(i) =
                                        L_SegNumDummy;
                        end loop;


                        if L_SegNumIndex <= L_FlexSeg_Counter then
                                L_Segment_Array(L_SegNumIndex) :=
                                        P_Inventory_Item_Segment20;
                        else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_OUT_OF_RANGE');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;

                        end if;
                end if;

                L_Delimiter := fnd_flex_ext.get_delimiter('INV',
                                                'MSTK',
                                                L_StructNum);

                if (L_TempSeg_Counter > 0) then

                        L_ConcatSegs := fnd_flex_ext.concatenate_segments(
                                        L_FlexSeg_Counter,
                                        L_Segment_Array,
                                        L_Delimiter);
                else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_FLEX_SEG_MISMATCH');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                end if;

                if L_ConcatSegs is not null then

                        L_Success := FND_FLEX_KEYVAL.Validate_Segs(
                                OPERATION       => 'FIND_COMBINATION',
                                APPL_SHORT_NAME => 'INV',
                                KEY_FLEX_CODE   => 'MSTK',
                                STRUCTURE_NUMBER=> L_StructNum,
                                CONCAT_SEGMENTS => L_ConcatSegs,
                                DATA_SET        => P_Master_Organization_Id
                                );

                        if L_Success then
                                P_Inventory_Item_Id :=
                                        FND_FLEX_KEYVAL.Combination_Id;

                        else
                                P_Inventory_Item_Id := NULL;
                        end if;

                        If P_Inventory_Item_Id is NULL then

                                FND_MESSAGE.Set_Name('INV',
                                        'INV_INVALID_CONTAINER');
                                FND_MESSAGE.Set_Token('COLUMN',
                                        'INVENTORY_ITEM', FALSE);
                                Manage_Error_Code('IN', 'APP-43014',
                                                Curr_Error);
                                RAISE Error;
                        END IF;

                else
                                FND_MESSAGE.Set_Name('INV',
                                        'INV_CONCAT_SEG_ERROR');
                                Manage_Error_Code('IN', 'APP-43014',
                                        Curr_Error);
                                RAISE Error;
                end if;

        ELSE
                FND_MESSAGE.Set_Name('INV', 'INV_NO_ITEM');
                Manage_Error_Code('IN', 'APP-43030', Curr_Error);
                RAISE Error;
        END IF;
--PLM 11.5.10 validation. XRef can be done only for Approved Items
        IF (P_Inventory_Item_Id IS NOT NULL) THEN
                SELECT  Inventory_Item_Id
                INTO    Temp_Inventory_Item_Id
                FROM    MTL_SYSTEM_ITEMS MSI
                WHERE   MSI.Inventory_Item_Id = P_Inventory_Item_Id
                AND     MSI.Organization_Id = P_Master_Organization_Id
                AND     NVL(MSI.Approval_Status,'A') = 'A';

       END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_INV_ITEM');
                IF (P_Inventory_Item_Id IS NOT NULL) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                        'INVENTORY_ITEM_ID', FALSE);
                ELSIF ((P_Inventory_Item_Id IS NULL) AND
                       (P_Inventory_Item IS NOT NULL)) THEN
                        FND_MESSAGE.Set_Token('COLUMN',
                                        'INVENTORY_ITEM', FALSE);
                ELSE
                        FND_MESSAGE.Set_Token('COLUMN',
                                        'INVENTORY_ITEM_SEGMENT1 - 20',
                                        FALSE);
                END IF;
                Manage_Error_Code('IN', 'APP-43031', Curr_Error);
                RAISE Error;

        WHEN TOO_MANY_ROWS THEN

                FND_MESSAGE.Set_Name('INV', 'INV_MULTIPLE_ITEMS');
                Manage_Error_Code('IN', 'APP-43056', Curr_Error);
                RAISE Error;

END Validate_Inventory_Item;


/*===========================================================================+
 +===========================================================================*/
/* These procedures will be shared by both Customer Item Open Interfaces.    */
/*===========================================================================+
 +===========================================================================*/

PROCEDURE Validate_Inactive_Flag(
        P_Inactive_Flag IN OUT  NOCOPY Varchar2
        )       IS

BEGIN

        IF ((P_Inactive_Flag = '1') OR (P_Inactive_Flag = '2')) THEN

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);

                IF (P_Inactive_Flag = '1') THEN
                        P_Inactive_Flag := 'Y';
                        RETURN;
                ELSE
                        P_Inactive_Flag := 'N';
                        RETURN;
                END IF;
        ELSE
                FND_MESSAGE.Set_Name('INV', 'INV_INVALID_INACTIVE_FLAG');
                Manage_Error_Code('IN', 'APP-43032', Curr_Error);
                RAISE Error;
        END IF;

END Validate_Inactive_Flag;


PROCEDURE Validate_Concurrent_Program   (       P_Request_Id                    IN      Number  DEFAULT NULL,
                                                P_Program_Application_Id        IN      Number  DEFAULT NULL,
                                                P_Program_Id                    IN      Number  DEFAULT NULL,
                                                P_Program_Update_Date           IN      Date    DEFAULT NULL    )       IS

BEGIN

        IF ((P_Request_Id IS NOT NULL) AND (P_Program_Application_Id IS NOT NULL) AND (P_Program_Id IS NOT NULL)
         AND (P_Program_Update_Date IS NOT NULL) AND (P_Program_Update_Date <= SYSDATE)) THEN

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;

        ELSE

                FND_MESSAGE.Set_Name('INV', 'INV_NO_CONCURRENT_PROG_INFO');
                Manage_Error_Code('IN', 'APP-43033', Curr_Error);
                RAISE Error;

        END IF;

END Validate_Concurrent_Program;


PROCEDURE Check_Uniqueness      (       P_Origin                        IN      Varchar2        DEFAULT NULL,
                                        P_Customer_Id                   IN      Number          DEFAULT NULL,
                                        P_Customer_Item_Number          IN      Varchar2        DEFAULT NULL,
                                        P_Item_Definition_Level         IN      Varchar2        DEFAULT NULL,
                                        P_Customer_Category_Code        IN      Varchar2        DEFAULT NULL,
                                        P_Address_Id                    IN      Number          DEFAULT NULL,
                                        P_Customer_Item_Id              IN      Number          DEFAULT NULL,
                                        P_Inventory_Item_Id             IN      Number          DEFAULT NULL,
                                        P_Master_Organization_Id        IN      Number          DEFAULT NULL,
                                        P_Preference_Number             IN      Number          DEFAULT NULL    )       IS


Temp_Customer_Id                Number          :=      NULL;
Temp_Customer_Item_Number       Varchar2(50)    :=      NULL;
Temp_Item_Definition_Level      Varchar2(1)     :=      NULL;
Temp_Customer_Category_Code     Varchar2(30)    :=      NULL;
Temp_Address_Id                 Number          :=      NULL;
Temp_Customer_Item_Id           Number          :=      NULL;
Temp_Inventory_Item_Id          Number          :=      NULL;
Temp_Master_Organization_Id     Number          :=      NULL;
Temp_Preference_Number          Number          :=      NULL;


BEGIN


        IF (P_Origin = 'I') THEN

                SELECT  Customer_Id, Customer_Item_Number, Item_Definition_Level, Customer_Category_Code, Address_Id
                INTO            Temp_Customer_Id, Temp_Customer_Item_Number, Temp_Item_Definition_Level, Temp_Customer_Category_Code, Temp_Address_Id
                FROM            MTL_CUSTOMER_ITEMS MCI
                WHERE           MCI.Customer_Id                                 =       P_Customer_Id
                AND             MCI.Customer_Item_Number                        =       P_Customer_Item_Number
                AND             MCI.Item_Definition_Level                       =       P_Item_Definition_Level
                AND             NVL(MCI.Customer_Category_Code, ' ')    =       NVL(P_Customer_Category_Code, ' ')
                AND             NVL(MCI.Address_Id, -1)                         =       NVL(P_Address_Id, -1);
                IF (SQL%FOUND) THEN
                        FND_MESSAGE.Set_Name('INV', 'INV_NON_UNIQUE_CI_RECORD');
                        Manage_Error_Code('IN', 'APP-43034', Curr_Error);
                        RAISE Error;
                END IF;

        ELSE


                SELECT  Customer_Item_Id, Inventory_Item_Id, Master_Organization_Id
                INTO            Temp_Customer_Item_Id, Temp_Inventory_Item_Id, Temp_Master_Organization_Id
                FROM            MTL_CUSTOMER_ITEM_XREFS MCIXRF
                WHERE           MCIXRF.Customer_Item_Id         =       P_Customer_Item_Id
                AND             MCIXRF.Inventory_Item_Id        =       P_Inventory_Item_Id
                AND             MCIXRF.Master_Organization_Id   =       P_Master_Organization_Id
                AND             Rownum                          =       1;

                IF (SQL%FOUND) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_NON_UNIQUE_CI_XREF_RECORD');
                        FND_MESSAGE.Set_Token('COLUMN1', 'CUSTOMER_ITEM_ID', FALSE);
                        FND_MESSAGE.Set_Token('COLUMN2', 'MASTER_ORGANIZATION_ID', FALSE);
                        FND_MESSAGE.Set_Token('COLUMN3', 'INVENTORY_ITEM_ID', FALSE);
                        Manage_Error_Code('IN', 'APP-43035', Curr_Error);
                        RAISE Error;

                ELSE

                        SELECT  Customer_Item_Id, Master_Organization_Id, Preference_Number
                        INTO            Temp_Customer_Item_Id, Temp_Master_Organization_Id, Temp_Preference_Number
                        FROM            MTL_CUSTOMER_ITEM_XREFS MCIXRF
                        WHERE           MCIXRF.Customer_Item_Id         =       P_Customer_Item_Id
                        AND             MCIXRF.Master_Organization_Id   =       P_Master_Organization_Id
                        AND             MCIXRF.Preference_Number        =       P_Preference_Number
                        AND             Rownum                          =       1;

                        IF (SQL%FOUND) THEN

                                FND_MESSAGE.Set_Name('INV', 'INV_NON_UNIQUE_CI_XREF_RECORD');
                                FND_MESSAGE.Set_Token('COLUMN1', 'CUSTOMER_ITEM_ID', FALSE);
                                FND_MESSAGE.Set_Token('COLUMN2', 'MASTER_ORGANIZATION_ID', FALSE);
                                FND_MESSAGE.Set_Token('COLUMN3', 'PREFERENCE_NUMBER', FALSE);
                                Manage_Error_Code('IN', 'APP-43035', Curr_Error);
                                RAISE Error;

                        END IF;

                END IF;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;

END Check_Uniqueness;

PROCEDURE Check_Required_Columns        (       P_Origin                        IN      Varchar2        DEFAULT NULL,
                                                P_Customer_Id                   IN      Number          DEFAULT NULL,
                                                P_Customer_Item_Number          IN      Varchar2        DEFAULT NULL,
                                                P_Item_Definition_Level         IN      Varchar2        DEFAULT NULL,
                                                P_Customer_Category_Code        IN      Varchar2        DEFAULT NULL,
                                                P_Address_Id                    IN      Number          DEFAULT NULL,
                                                P_Inactive_Flag                 IN      Varchar2        DEFAULT NULL,
                                                P_Last_Updated_By               IN      Number          DEFAULT NULL,
                                                P_Last_Update_Date              IN      Date            DEFAULT NULL,
                                                P_Created_By                    IN      Number          DEFAULT NULL,
                                                P_Creation_Date                 IN      Date            DEFAULT NULL,
                                                P_Customer_Item_Id              IN      Number          DEFAULT NULL,
                                                P_Inventory_Item_Id             IN      Number          DEFAULT NULL,
                                                P_Master_Organization_Id        IN      Number          DEFAULT NULL,
                                                P_Preference_Number             IN      Number          DEFAULT NULL    )       IS

BEGIN

        IF (P_Origin = 'I') THEN

                IF ((P_Customer_Id IS NULL) OR
                    (P_Customer_Item_Number IS NULL) OR
                    (P_Item_Definition_Level IS NULL) OR
                    ((P_Item_Definition_Level = '2') AND (P_Customer_Category_Code IS NULL)) OR
                    ((P_Item_Definition_Level = '3') AND (P_Address_Id IS NULL)) OR
                    (P_Inactive_Flag IS NULL) OR
                    (P_Last_Updated_By IS NULL) OR
                    (P_Last_Update_Date IS NULL) OR
                    (P_Created_By IS NULL) OR
                    (P_Creation_Date IS NULL)) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_REQUIRED_COLUMNS_MISSING');
                        Manage_Error_Code('IN', 'APP-43036', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        RETURN;

                END IF;

        ELSE

                IF ((P_Customer_Item_Id IS NULL) OR
                    (P_Inventory_Item_Id IS NULL) OR
                    (P_Master_Organization_Id IS NULL) OR
                    (P_Preference_Number IS NULL) OR
                    (P_Inactive_Flag IS NULL) OR
                    (P_Last_Updated_By IS NULL) OR
                    (P_Last_Update_Date IS NULL) OR
                    (P_Created_By IS NULL) OR
                    (P_Creation_Date IS NULL)) THEN

                        FND_MESSAGE.Set_Name('INV', 'INV_REQUIRED_COLUMNS_MISSING');
                        Manage_Error_Code('IN', 'APP-43036', Curr_Error);
                        RAISE Error;

                ELSE

                        Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                        RETURN;

                END IF;

        END IF;

END Check_Required_Columns;


PROCEDURE Insert_Row(
        P_Origin                        IN Varchar2     DEFAULT NULL,
        P_Last_Update_Date              IN Date         DEFAULT NULL,
        P_Last_Updated_By               IN Number       DEFAULT NULL,
        P_Creation_Date                 IN Date         DEFAULT NULL,
        P_Created_By                    IN Number       DEFAULT NULL,
        P_Last_Update_Login             IN Number       DEFAULT NULL,
        P_Customer_Id                   IN Number       DEFAULT NULL,
        P_Customer_Category_Code        IN Varchar2     DEFAULT NULL,
        P_Address_Id                    IN Number       DEFAULT NULL,
        P_Customer_Item_Number          IN Varchar2     DEFAULT NULL,
        P_Item_Definition_Level         IN Varchar2     DEFAULT NULL,
        P_Customer_Item_Desc            IN Varchar2     DEFAULT NULL,
        P_Model_Customer_Item_Id        IN Number       DEFAULT NULL,
        P_Commodity_Code_Id             IN Number       DEFAULT NULL,
        P_Master_Container_Item_Id      IN Number       DEFAULT NULL,
        P_Container_Item_Org_Id         IN Number       DEFAULT NULL,
        P_Detail_Container_Item_Id      IN Number       DEFAULT NULL,
        P_Min_Fill_Percentage           IN Number       DEFAULT NULL,
        P_Dep_Plan_Required_Flag        IN Varchar2     DEFAULT NULL,
        P_Dep_Plan_Prior_Bld_Flag       IN Varchar2     DEFAULT NULL,
        P_Inactive_Flag                 IN Varchar2     DEFAULT NULL,
        P_Attribute_Category            IN Varchar2     DEFAULT NULL,
        P_Attribute1                    IN Varchar2     DEFAULT NULL,
        P_Attribute2                    IN Varchar2     DEFAULT NULL,
        P_Attribute3                    IN Varchar2     DEFAULT NULL,
        P_Attribute4                    IN Varchar2     DEFAULT NULL,
        P_Attribute5                    IN Varchar2     DEFAULT NULL,
        P_Attribute6                    IN Varchar2     DEFAULT NULL,
        P_Attribute7                    IN Varchar2     DEFAULT NULL,
        P_Attribute8                    IN Varchar2     DEFAULT NULL,
        P_Attribute9                    IN Varchar2     DEFAULT NULL,
        P_Attribute10                   IN Varchar2     DEFAULT NULL,
        P_Attribute11                   IN Varchar2     DEFAULT NULL,
        P_Attribute12                   IN Varchar2     DEFAULT NULL,
        P_Attribute13                   IN Varchar2     DEFAULT NULL,
        P_Attribute14                   IN Varchar2     DEFAULT NULL,
        P_Attribute15                   IN Varchar2     DEFAULT NULL,
        P_Demand_Tolerance_Positive     IN Number       DEFAULT NULL,
        P_Demand_Tolerance_Negative     IN Number       DEFAULT NULL,
        P_Request_Id                    IN Number       DEFAULT NULL,
        P_Program_Application_Id        IN Number       DEFAULT NULL,
        P_Program_Id                    IN Number       DEFAULT NULL,
        P_Program_Update_Date           IN Date         DEFAULT NULL,
        P_Customer_Item_Id              IN Number       DEFAULT NULL,
        P_Inventory_Item_Id             IN Number       DEFAULT NULL,
        P_Master_Organization_Id        IN Number       DEFAULT NULL,
        P_Preference_Number             IN Number       DEFAULT NULL
        )       IS

BEGIN

        IF (P_Origin = 'I') THEN

                INSERT
                INTO MTL_CUSTOMER_ITEMS(
                        Customer_Item_Id,
                        Last_Update_Date,
                        Last_Updated_By,
                        Creation_Date,
                        Created_By,
                        Last_Update_Login,
                        Customer_Id,
                        Customer_Category_Code,
                        Address_Id,
                        Customer_Item_Number,
                        Item_Definition_Level,
                        Customer_Item_Desc,
                        Model_Customer_Item_Id,
                        Commodity_Code_Id,
                        Master_Container_Item_Id,
                        Container_Item_Org_Id,
                        Detail_Container_Item_Id,
                        Min_Fill_Percentage,
                        Dep_Plan_Required_Flag,
                        Dep_Plan_Prior_Bld_Flag,
                        Inactive_Flag,
                        Attribute_Category,
                        Attribute1,
                        Attribute2,
                        Attribute3,
                        Attribute4,
                        Attribute5,
                        Attribute6,
                        Attribute7,
                        Attribute8,
                        Attribute9,
                        Attribute10,
                        Attribute11,
                        Attribute12,
                        Attribute13,
                        Attribute14,
                        Attribute15,
                        Demand_Tolerance_Positive,
                        Demand_Tolerance_Negative,
                        Request_Id,
                        Program_Application_Id,
                        Program_Id,
                        Program_Update_Date
                        )
                VALUES
                        (
                        MTL_CUSTOMER_ITEMS_S.Nextval,
                        SYSDATE,
                        NVL(P_Last_Updated_By, -1),
                        SYSDATE,
                        NVL(P_Created_By, -1),
                        NVL(P_Last_Update_Login,-1),
                        P_Customer_Id,
                        P_Customer_Category_Code,
                        P_Address_Id,
                        P_Customer_Item_Number,
                        P_Item_Definition_Level,
                        trim(P_Customer_Item_Desc),
                        P_Model_Customer_Item_Id,
                        P_Commodity_Code_Id,
                        P_Master_Container_Item_Id,
                        P_Container_Item_Org_Id,
                        P_Detail_Container_Item_Id,
                        P_Min_Fill_Percentage,
                        P_Dep_Plan_Required_Flag,
                        P_Dep_Plan_Prior_Bld_Flag,
                        P_Inactive_Flag,
                        P_Attribute_Category,
                        P_Attribute1,
                        P_Attribute2,
                        P_Attribute3,
                        P_Attribute4,
                        P_Attribute5,
                        P_Attribute6,
                        P_Attribute7,
                        P_Attribute8,
                        P_Attribute9,
                        P_Attribute10,
                        P_Attribute11,
                        P_Attribute12,
                        P_Attribute13,
                        P_Attribute14,
                        P_Attribute15,
                        P_Demand_Tolerance_Positive,
                        P_Demand_Tolerance_Negative,
                        P_Request_Id,
                        P_Program_Application_Id,
                        P_Program_Id,
                        P_Program_Update_Date
                        );

        ELSE

                INSERT
                INTO MTL_CUSTOMER_ITEM_XREFS
                        (
                        Customer_Item_Id,
                        Inventory_Item_Id,
                        Master_Organization_Id,
                        Preference_Number,
                        Inactive_Flag,
                        Last_Update_Date,
                        Last_Updated_By,
                        Creation_Date,
                        Created_By,
                        Last_Update_Login,
                        Attribute_Category,
                        Attribute1,
                        Attribute2,
                        Attribute3,
                        Attribute4,
                        Attribute5,
                        Attribute6,
                        Attribute7,
                        Attribute8,
                        Attribute9,
                        Attribute10,
                        Attribute11,
                        Attribute12,
                        Attribute13,
                        Attribute14,
                        Attribute15,
                        Request_Id,
                        Program_Application_Id,
                        Program_Id,
                        Program_Update_Date
                        )
                VALUES
                        (
                        P_Customer_Item_Id,
                        P_Inventory_Item_Id,
                        P_Master_Organization_Id,
                        P_Preference_Number,
                        P_Inactive_Flag,
                        SYSDATE,
                        NVL(P_Last_Updated_By, -1),
                        SYSDATE,
                        NVL(P_Created_By, -1),
                        NVL(P_Last_Update_Login, -1),
                        P_Attribute_Category,
                        P_Attribute1,
                        P_Attribute2,
                        P_Attribute3,
                        P_Attribute4,
                        P_Attribute5,
                        P_Attribute6,
                        P_Attribute7,
                        P_Attribute8,
                        P_Attribute9,
                        P_Attribute10,
                        P_Attribute11,
                        P_Attribute12,
                        P_Attribute13,
                        P_Attribute14,
                        P_Attribute15,
                        P_Request_Id,
                        P_Program_Application_Id,
                        P_Program_Id,
                        P_Program_Update_Date
                        );

        END IF;

        IF ((SQL%FOUND) AND (SQL%ROWCOUNT = 1)) THEN

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;

        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_NO_ROW_INSERTED');
                Manage_Error_Code('IN', 'APP-43025', Curr_Error);
                RAISE Error;

END Insert_Row;


PROCEDURE Delete_Row(
        P_Origin                IN Varchar2     DEFAULT NULL,
        P_Delete_Record         IN Varchar2     DEFAULT NULL,
        P_Temp_RowId            IN Varchar2     DEFAULT NULL
        )       IS

BEGIN

        IF ((P_Origin = 'I') AND (UPPER(P_Delete_Record) = 'Y')) THEN

                DELETE
                FROM    MTL_CI_INTERFACE
                WHERE   Rowid           =       P_Temp_RowId;

        ELSIF ((P_Origin = 'X') AND (UPPER(P_Delete_Record) = 'Y')) THEN

                DELETE
                FROM    MTL_CI_XREFS_INTERFACE
                WHERE   Rowid           =       P_Temp_RowId;

        ELSIF ((P_Origin = 'I') AND (UPPER(P_Delete_Record) = 'N')) THEN

                UPDATE  MTL_CI_INTERFACE
                SET             Process_Mode    =       3
                WHERE           Rowid                   =       P_Temp_RowId;

        ELSIF ((P_Origin = 'X') AND (UPPER(P_Delete_Record) = 'N')) THEN

                UPDATE  MTL_CI_XREFS_INTERFACE
                SET             Process_Mode    =       3
                WHERE           Rowid                   =       P_Temp_RowId;

        ELSE
                NULL;
        END IF;

        IF ((SQL%FOUND) AND (SQL%ROWCOUNT = 1)) THEN

                Manage_Error_Code('IN', 'APP-00000', Curr_Error);
                RETURN;
        END IF;

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                FND_MESSAGE.Set_Name('INV', 'INV_NO_ROW_DELETED');
                Manage_Error_Code('IN', 'APP-43026', Curr_Error);
                RAISE Error;

END Delete_Row;

PROCEDURE Manage_Error_Code(
        P_Action                IN      Varchar2        DEFAULT 'IN',
        Error_Code              IN      Varchar2        DEFAULT NULL,
        Curr_Error              OUT     NOCOPY Varchar2
        )       IS

BEGIN
        IF (P_Action = 'IN') THEN
                Current_Error_Code := Error_Code  ;
        ELSIF (P_Action = 'OUT') THEN
                Curr_Error := Current_Error_Code;
        END IF;
END Manage_Error_Code;


END INVCIINT;

/
