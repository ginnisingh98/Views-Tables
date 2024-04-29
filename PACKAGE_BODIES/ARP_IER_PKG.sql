--------------------------------------------------------
--  DDL for Package Body ARP_IER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_IER_PKG" as
/* $Header: ARXIIERB.pls 115.5 2003/10/10 14:31:05 mraymond ship $ */

--
-- PRIVATE Procedures/Functions
--

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Check_Eff_Date_Overlap (
			 p_Rowid                   	VARCHAR2,
			 p_Item_Id                        NUMBER,
			 p_Start_Date                     DATE,
			 p_End_Date                       DATE,
			 p_Location_Id_Segment_1          NUMBER,
			 p_Location_Id_Segment_2          NUMBER,
			 p_Location_Id_Segment_3          NUMBER,
			 p_Location_Id_Segment_4          NUMBER,
			 p_Location_Id_Segment_5          NUMBER,
			 p_Location_Id_Segment_6          NUMBER,
			 p_Location_Id_Segment_7          NUMBER,
			 p_Location_Id_Segment_8          NUMBER,
			 p_Location_Id_Segment_9          NUMBER,
			 p_Location_Id_Segment_10         NUMBER ) IS
    l_nrecs		number;

    -- Get Exception with overlapping date
    CURSOR Sel_Date_Overlap IS
	Select 1
	From   RA_item_exception_rates
	Where  item_id = p_item_id
	  And  nvl(location_id_segment_1,0) =
			  nvl(p_location_id_segment_1,0)
	  And  nvl(location_id_segment_2,0) =
			  nvl(p_location_id_segment_2,0)
	  And  nvl(location_id_segment_3,0) =
			  nvl(p_location_id_segment_3,0)
	  And  nvl(location_id_segment_4,0) =
			  nvl(p_location_id_segment_4,0)
	  And  nvl(location_id_segment_5,0) =
			  nvl(p_location_id_segment_5,0)
	  And  nvl(location_id_segment_6,0) =
			  nvl(p_location_id_segment_6,0)
	  And  nvl(location_id_segment_7,0) =
			  nvl(p_location_id_segment_7,0)
	  And  nvl(location_id_segment_8,0) =
			  nvl(p_location_id_segment_8,0)
	  And  nvl(location_id_segment_9,0) =
			  nvl(p_location_id_segment_9,0)
	  And  nvl(location_id_segment_10,0) =
			  nvl(p_location_id_segment_10,0)
	  And  ( p_start_date between
		 start_date AND nvl(end_date, p_start_date)
	     OR  start_date between p_start_date AND
				 nvl(p_end_date, start_date) )
	  And  ( p_rowid is null
	     OR   rowid <> p_rowid );

  BEGIN
    -- Check if Dates overlap any existing rates for the
    -- Item's Location authority.

      If ( p_end_date is NULL OR (p_end_date >= p_start_date) ) Then

	OPEN Sel_Date_Overlap;
	FETCH Sel_Date_Overlap INTO l_nrecs;

	If ( Sel_Date_Overlap%FOUND ) then

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Check_Eff_Date_Overlap: ' || '-- FOUND Overlap ');
          END IF;
	  CLOSE Sel_Date_Overlap;

	  Fnd_Message.Set_name('AR', 'AR_RATE_OVERLAP_DATE');
          APP_EXCEPTION.Raise_Exception;
	Else
	  CLOSE Sel_Date_Overlap;
	End if;

      Else
	-- End Date < Start Date?
	Fnd_Message.Set_name('AR', 'AR_VAL_START');
        APP_EXCEPTION.Raise_Exception;
      End if;

  END Check_Eff_Date_Overlap;

--
-- PUBLIC Procedures/Functions
--


  PROCEDURE Insert_Row(p_Rowid                   IN OUT NOCOPY VARCHAR2,
                       p_Item_Exception_Rate_Id         IN OUT NOCOPY NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Last_Updated_By                NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Item_Id                        NUMBER,
                       p_Rate_Context                   VARCHAR2,
                       p_Location1_Rate                 NUMBER,
                       p_Location2_Rate                 NUMBER,
                       p_Location3_Rate                 NUMBER,
                       p_Location4_Rate                 NUMBER,
                       p_Location5_Rate                 NUMBER,
                       p_Location6_Rate                 NUMBER,
                       p_Location7_Rate                 NUMBER,
                       p_Location8_Rate                 NUMBER,
                       p_Location9_Rate                 NUMBER,
                       p_Location10_Rate                NUMBER,
                       p_Start_Date                     DATE,
                       p_End_Date                       DATE,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
                       p_Reason_Code                    VARCHAR2,
                       p_Location_Context               VARCHAR2,
                       p_Location_Id_Segment_1          NUMBER,
                       p_Location_Id_Segment_2          NUMBER,
                       p_Location_Id_Segment_3          NUMBER,
                       p_Location_Id_Segment_4          NUMBER,
                       p_Location_Id_Segment_5          NUMBER,
                       p_Location_Id_Segment_6          NUMBER,
                       p_Location_Id_Segment_7          NUMBER,
                       p_Location_Id_Segment_8          NUMBER,
                       p_Location_Id_Segment_9          NUMBER,
                       p_Location_Id_Segment_10         NUMBER,
                       p_org_id                         NUMBER  DEFAULT -1 -- Bug 3098063
  ) IS
    CURSOR C IS SELECT rowid FROM RA_ITEM_EXCEPTION_RATES
                 WHERE item_exception_rate_id = p_Item_Exception_Rate_Id;
      CURSOR C2 IS SELECT ra_item_exception_rates_s.nextval FROM dual;
   BEGIN

     -- Check if Effective Dates overlap.
     --
     Check_Eff_Date_Overlap ( p_Rowid, p_Item_Id, p_Start_Date, p_End_Date,
			p_Location_Id_Segment_1, p_Location_Id_Segment_2,
			p_Location_Id_Segment_3, p_Location_Id_Segment_4,
			p_Location_Id_Segment_5, p_Location_Id_Segment_6,
			p_Location_Id_Segment_7, p_Location_Id_Segment_8,
			p_Location_Id_Segment_9, p_Location_Id_Segment_10 );


      if (p_Item_Exception_Rate_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO p_Item_Exception_Rate_Id;
        CLOSE C2;
      end if;

       INSERT INTO RA_ITEM_EXCEPTION_RATES(

              item_exception_rate_id,
              creation_date,
              created_by,
              last_update_login,
              last_updated_by,
              last_update_date,
              item_id,
              rate_context,
              location1_rate,
              location2_rate,
              location3_rate,
              location4_rate,
              location5_rate,
              location6_rate,
              location7_rate,
              location8_rate,
              location9_rate,
              location10_rate,
              start_date,
              end_date,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              reason_code,
              location_context,
              location_id_segment_1,
              location_id_segment_2,
              location_id_segment_3,
              location_id_segment_4,
              location_id_segment_5,
              location_id_segment_6,
              location_id_segment_7,
              location_id_segment_8,
              location_id_segment_9,
              location_id_segment_10
             ) VALUES (

              p_Item_Exception_Rate_Id,
              p_Creation_Date,
              p_Created_By,
              p_Last_Update_Login,
              p_Last_Updated_By,
              p_Last_Update_Date,
              p_Item_Id,
              p_Rate_Context,
              p_Location1_Rate,
              p_Location2_Rate,
              p_Location3_Rate,
              p_Location4_Rate,
              p_Location5_Rate,
              p_Location6_Rate,
              p_Location7_Rate,
              p_Location8_Rate,
              p_Location9_Rate,
              p_Location10_Rate,
              p_Start_Date,
              p_End_Date,
              p_Attribute_Category,
              p_Attribute1,
              p_Attribute2,
              p_Attribute3,
              p_Attribute4,
              p_Attribute5,
              p_Attribute6,
              p_Attribute7,
              p_Attribute8,
              p_Attribute9,
              p_Attribute10,
              p_Attribute11,
              p_Attribute12,
              p_Attribute13,
              p_Attribute14,
              p_Attribute15,
              p_Reason_Code,
              p_Location_Context,
              p_Location_Id_Segment_1,
              p_Location_Id_Segment_2,
              p_Location_Id_Segment_3,
              p_Location_Id_Segment_4,
              p_Location_Id_Segment_5,
              p_Location_Id_Segment_6,
              p_Location_Id_Segment_7,
              p_Location_Id_Segment_8,
              p_Location_Id_Segment_9,
              p_Location_Id_Segment_10

             );

    OPEN C;
    FETCH C INTO p_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    -- Bug 3098063
    -- Implemented eTax Synchronization Control Procedure
    ZX_UPGRADE_CONTROL_PKG.SYNC_AR_TAX_EXCEPTIONS
    (
    P_Dml_Type                       => 'I',
    P_Org_Id                         => P_org_id,
    P_Item_Exception_Rate_Id         => P_Item_Exception_Rate_Id,
    P_Creation_Date                  => P_Creation_Date,
    P_Created_By                     => P_Created_By,
    P_Last_Update_Login              => P_Last_Update_Login,
    P_Last_Updated_By                => P_Last_Updated_By,
    P_Last_Update_Date               => P_Last_Update_Date,
    P_Item_Id                        => P_Item_Id,
    P_Rate_Context                   => P_Rate_Context,
    P_Location1_Rate                 => P_Location1_Rate,
    P_Location2_Rate                 => P_Location2_Rate,
    P_Location3_Rate                 => P_Location3_Rate,
    P_Location4_Rate                 => P_Location4_Rate,
    P_Location5_Rate                 => P_Location5_Rate,
    P_Location6_Rate                 => P_Location6_Rate,
    P_Location7_Rate                 => P_Location7_Rate,
    P_Location8_Rate                 => P_Location8_Rate,
    P_Location9_Rate                 => P_Location9_Rate,
    P_Location10_Rate                => P_Location10_Rate,
    P_Start_Date                     => P_Start_Date,
    P_End_Date                       => P_End_Date,
    P_Attribute_Category             => P_Attribute_Category,
    P_Attribute1                     => P_Attribute1,
    P_Attribute2                     => P_Attribute2,
    P_Attribute3                     => P_Attribute3,
    P_Attribute4                     => P_Attribute4,
    P_Attribute5                     => P_Attribute5,
    P_Attribute6                     => P_Attribute6,
    P_Attribute7                     => P_Attribute7,
    P_Attribute8                     => P_Attribute8,
    P_Attribute9                     => P_Attribute9,
    P_Attribute10                    => P_Attribute10,
    P_Attribute11                    => P_Attribute11,
    P_Attribute12                    => P_Attribute12,
    P_Attribute13                    => P_Attribute13,
    P_Attribute14                    => P_Attribute14,
    P_Attribute15                    => P_Attribute15,
    P_Reason_Code                    => P_Reason_Code,
    P_Location_Context               => P_Location_Context,
    P_Location_Id_Segment_1          => P_Location_Id_Segment_1,
    P_Location_Id_Segment_2          => P_Location_Id_Segment_2,
    P_Location_Id_Segment_3          => P_Location_Id_Segment_3,
    P_Location_Id_Segment_4          => P_Location_Id_Segment_4,
    P_Location_Id_Segment_5          => P_Location_Id_Segment_5,
    P_Location_Id_Segment_6          => P_Location_Id_Segment_6,
    P_Location_Id_Segment_7          => P_Location_Id_Segment_7,
    P_Location_Id_Segment_8          => P_Location_Id_Segment_8,
    P_Location_Id_Segment_9          => P_Location_Id_Segment_9,
    P_Location_Id_Segment_10         => P_Location_Id_Segment_10
    );

  END Insert_Row;


  PROCEDURE Lock_Row(p_Rowid                            VARCHAR2,
                     p_Item_Exception_Rate_Id           NUMBER,
                     p_Item_Id                          NUMBER,
                     p_Rate_Context                     VARCHAR2,
                     p_Location1_Rate                   NUMBER,
                     p_Location2_Rate                   NUMBER,
                     p_Location3_Rate                   NUMBER,
                     p_Location4_Rate                   NUMBER,
                     p_Location5_Rate                   NUMBER,
                     p_Location6_Rate                   NUMBER,
                     p_Location7_Rate                   NUMBER,
                     p_Location8_Rate                   NUMBER,
                     p_Location9_Rate                   NUMBER,
                     p_Location10_Rate                  NUMBER,
                     p_Start_Date                       DATE,
                     p_End_Date                         DATE,
                     p_Attribute_Category               VARCHAR2,
                     p_Attribute1                       VARCHAR2,
                     p_Attribute2                       VARCHAR2,
                     p_Attribute3                       VARCHAR2,
                     p_Attribute4                       VARCHAR2,
                     p_Attribute5                       VARCHAR2,
                     p_Attribute6                       VARCHAR2,
                     p_Attribute7                       VARCHAR2,
                     p_Attribute8                       VARCHAR2,
                     p_Attribute9                       VARCHAR2,
                     p_Attribute10                      VARCHAR2,
                     p_Attribute11                      VARCHAR2,
                     p_Attribute12                      VARCHAR2,
                     p_Attribute13                      VARCHAR2,
                     p_Attribute14                      VARCHAR2,
                     p_Attribute15                      VARCHAR2,
                     p_Reason_Code                      VARCHAR2,
                     p_Location_Context                 VARCHAR2,
                     p_Location_Id_Segment_1            NUMBER,
                     p_Location_Id_Segment_2            NUMBER,
                     p_Location_Id_Segment_3            NUMBER,
                     p_Location_Id_Segment_4            NUMBER,
                     p_Location_Id_Segment_5            NUMBER,
                     p_Location_Id_Segment_6            NUMBER,
                     p_Location_Id_Segment_7            NUMBER,
                     p_Location_Id_Segment_8            NUMBER,
                     p_Location_Id_Segment_9            NUMBER,
                     p_Location_Id_Segment_10           NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   RA_ITEM_EXCEPTION_RATES
        WHERE  rowid = p_Rowid
        FOR UPDATE of Item_Exception_Rate_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if ( (Recinfo.item_exception_rate_id =  p_Item_Exception_Rate_Id)
           AND (Recinfo.item_id =  p_Item_Id)
           AND (Recinfo.rate_context =  p_Rate_Context)
           AND (   (Recinfo.location1_rate =  p_Location1_Rate)
                OR (    (Recinfo.location1_rate IS NULL)
                    AND (p_Location1_Rate IS NULL)))
           AND (   (Recinfo.location2_rate =  p_Location2_Rate)
                OR (    (Recinfo.location2_rate IS NULL)
                    AND (p_Location2_Rate IS NULL)))
           AND (   (Recinfo.location3_rate =  p_Location3_Rate)
                OR (    (Recinfo.location3_rate IS NULL)
                    AND (p_Location3_Rate IS NULL)))
           AND (   (Recinfo.location4_rate =  p_Location4_Rate)
                OR (    (Recinfo.location4_rate IS NULL)
                    AND (p_Location4_Rate IS NULL)))
           AND (   (Recinfo.location5_rate =  p_Location5_Rate)
                OR (    (Recinfo.location5_rate IS NULL)
                    AND (p_Location5_Rate IS NULL)))
           AND (   (Recinfo.location6_rate =  p_Location6_Rate)
                OR (    (Recinfo.location6_rate IS NULL)
                    AND (p_Location6_Rate IS NULL)))
           AND (   (Recinfo.location7_rate =  p_Location7_Rate)
                OR (    (Recinfo.location7_rate IS NULL)
                    AND (p_Location7_Rate IS NULL)))
           AND (   (Recinfo.location8_rate =  p_Location8_Rate)
                OR (    (Recinfo.location8_rate IS NULL)
                    AND (p_Location8_Rate IS NULL)))
           AND (   (Recinfo.location9_rate =  p_Location9_Rate)
                OR (    (Recinfo.location9_rate IS NULL)
                    AND (p_Location9_Rate IS NULL)))
           AND (   (Recinfo.location10_rate =  p_Location10_Rate)
                OR (    (Recinfo.location10_rate IS NULL)
                    AND (p_Location10_Rate IS NULL)))
           AND (Recinfo.start_date =  p_Start_Date)
           AND (   (Recinfo.end_date =  p_End_Date)
                OR (    (Recinfo.end_date IS NULL)
                    AND (p_End_Date IS NULL)))
           AND (   (Recinfo.attribute_category =  p_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (p_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  p_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (p_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  p_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (p_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  p_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (p_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  p_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (p_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  p_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (p_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  p_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (p_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  p_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (p_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  p_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (p_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  p_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (p_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  p_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (p_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  p_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (p_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  p_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (p_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  p_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (p_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  p_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (p_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  p_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (p_Attribute15 IS NULL)))
           AND (Recinfo.reason_code =  p_Reason_Code)
           AND (Recinfo.location_context =  p_Location_Context)
           AND (   (Recinfo.location_id_segment_1 =  p_Location_Id_Segment_1)
                OR (    (Recinfo.location_id_segment_1 IS NULL)
                    AND (p_Location_Id_Segment_1 IS NULL)))
           AND (   (Recinfo.location_id_segment_2 =  p_Location_Id_Segment_2)
                OR (    (Recinfo.location_id_segment_2 IS NULL)
                    AND (p_Location_Id_Segment_2 IS NULL)))
           AND (   (Recinfo.location_id_segment_3 =  p_Location_Id_Segment_3)
                OR (    (Recinfo.location_id_segment_3 IS NULL)
                    AND (p_Location_Id_Segment_3 IS NULL)))
           AND (   (Recinfo.location_id_segment_4 =  p_Location_Id_Segment_4)
                OR (    (Recinfo.location_id_segment_4 IS NULL)
                    AND (p_Location_Id_Segment_4 IS NULL)))
           AND (   (Recinfo.location_id_segment_5 =  p_Location_Id_Segment_5)
                OR (    (Recinfo.location_id_segment_5 IS NULL)
                    AND (p_Location_Id_Segment_5 IS NULL)))
           AND (   (Recinfo.location_id_segment_6 =  p_Location_Id_Segment_6)
                OR (    (Recinfo.location_id_segment_6 IS NULL)
                    AND (p_Location_Id_Segment_6 IS NULL)))
           AND (   (Recinfo.location_id_segment_7 =  p_Location_Id_Segment_7)
                OR (    (Recinfo.location_id_segment_7 IS NULL)
                    AND (p_Location_Id_Segment_7 IS NULL)))
           AND (   (Recinfo.location_id_segment_8 =  p_Location_Id_Segment_8)
                OR (    (Recinfo.location_id_segment_8 IS NULL)
                    AND (p_Location_Id_Segment_8 IS NULL)))
           AND (   (Recinfo.location_id_segment_9 =  p_Location_Id_Segment_9)
                OR (    (Recinfo.location_id_segment_9 IS NULL)
                    AND (p_Location_Id_Segment_9 IS NULL)))
           AND (   (Recinfo.location_id_segment_10 =  p_Location_Id_Segment_10)
                OR (    (Recinfo.location_id_segment_10 IS NULL)
                    AND (p_Location_Id_Segment_10 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(p_Rowid                          VARCHAR2,
                       p_Item_Exception_Rate_Id         NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Last_Updated_By                NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Item_Id                        NUMBER,
                       p_Rate_Context                   VARCHAR2,
                       p_Location1_Rate                 NUMBER,
                       p_Location2_Rate                 NUMBER,
                       p_Location3_Rate                 NUMBER,
                       p_Location4_Rate                 NUMBER,
                       p_Location5_Rate                 NUMBER,
                       p_Location6_Rate                 NUMBER,
                       p_Location7_Rate                 NUMBER,
                       p_Location8_Rate                 NUMBER,
                       p_Location9_Rate                 NUMBER,
                       p_Location10_Rate                NUMBER,
                       p_Start_Date                     DATE,
                       p_End_Date                       DATE,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
                       p_Reason_Code                    VARCHAR2,
                       p_Location_Context               VARCHAR2,
                       p_Location_Id_Segment_1          NUMBER,
                       p_Location_Id_Segment_2          NUMBER,
                       p_Location_Id_Segment_3          NUMBER,
                       p_Location_Id_Segment_4          NUMBER,
                       p_Location_Id_Segment_5          NUMBER,
                       p_Location_Id_Segment_6          NUMBER,
                       p_Location_Id_Segment_7          NUMBER,
                       p_Location_Id_Segment_8          NUMBER,
                       p_Location_Id_Segment_9          NUMBER,
                       p_Location_Id_Segment_10         NUMBER,
                       p_org_id                         NUMBER  DEFAULT -1 -- Bug 3098063

  ) IS
  BEGIN

    -- Check if Effective Dates overlap.
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Update_Row: ' || '-- Checking Overlap ');
    END IF;
    Check_Eff_Date_Overlap ( p_Rowid, p_Item_Id, p_Start_Date, p_End_Date,
			p_Location_Id_Segment_1, p_Location_Id_Segment_2,
			p_Location_Id_Segment_3, p_Location_Id_Segment_4,
			p_Location_Id_Segment_5, p_Location_Id_Segment_6,
			p_Location_Id_Segment_7, p_Location_Id_Segment_8,
			p_Location_Id_Segment_9, p_Location_Id_Segment_10 );

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Update_Row: ' || '-- Updating Row');
       arp_util.debug('Update_Row: ' || '-- p_Rowid = '||p_Rowid);
    END IF;

    UPDATE RA_ITEM_EXCEPTION_RATES
    SET
       item_exception_rate_id          =     p_Item_Exception_Rate_Id,
       last_update_login               =     p_Last_Update_Login,
       last_updated_by                 =     p_Last_Updated_By,
       last_update_date                =     p_Last_Update_Date,
       item_id                         =     p_Item_Id,
       rate_context                    =     p_Rate_Context,
       location1_rate                  =     p_Location1_Rate,
       location2_rate                  =     p_Location2_Rate,
       location3_rate                  =     p_Location3_Rate,
       location4_rate                  =     p_Location4_Rate,
       location5_rate                  =     p_Location5_Rate,
       location6_rate                  =     p_Location6_Rate,
       location7_rate                  =     p_Location7_Rate,
       location8_rate                  =     p_Location8_Rate,
       location9_rate                  =     p_Location9_Rate,
       location10_rate                 =     p_Location10_Rate,
       start_date                      =     p_Start_Date,
       end_date                        =     p_End_Date,
       attribute_category              =     p_Attribute_Category,
       attribute1                      =     p_Attribute1,
       attribute2                      =     p_Attribute2,
       attribute3                      =     p_Attribute3,
       attribute4                      =     p_Attribute4,
       attribute5                      =     p_Attribute5,
       attribute6                      =     p_Attribute6,
       attribute7                      =     p_Attribute7,
       attribute8                      =     p_Attribute8,
       attribute9                      =     p_Attribute9,
       attribute10                     =     p_Attribute10,
       attribute11                     =     p_Attribute11,
       attribute12                     =     p_Attribute12,
       attribute13                     =     p_Attribute13,
       attribute14                     =     p_Attribute14,
       attribute15                     =     p_Attribute15,
       reason_code                     =     p_Reason_Code,
       location_context                =     p_Location_Context,
       location_id_segment_1           =     p_Location_Id_Segment_1,
       location_id_segment_2           =     p_Location_Id_Segment_2,
       location_id_segment_3           =     p_Location_Id_Segment_3,
       location_id_segment_4           =     p_Location_Id_Segment_4,
       location_id_segment_5           =     p_Location_Id_Segment_5,
       location_id_segment_6           =     p_Location_Id_Segment_6,
       location_id_segment_7           =     p_Location_Id_Segment_7,
       location_id_segment_8           =     p_Location_Id_Segment_8,
       location_id_segment_9           =     p_Location_Id_Segment_9,
       location_id_segment_10          =     p_Location_Id_Segment_10
    WHERE rowid = p_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    -- Bug 3098063
    -- Implemented eTax Synchronization Control Procedure
    ZX_UPGRADE_CONTROL_PKG.SYNC_AR_TAX_EXCEPTIONS
    (
    P_Dml_Type                       => 'U',
    P_Org_Id                         => P_org_id,
    P_Item_Exception_Rate_Id         => P_Item_Exception_Rate_Id,
    P_Creation_Date                  => NULL,
    P_Created_By                     => NULL,
    P_Last_Update_Login              => P_Last_Update_Login,
    P_Last_Updated_By                => P_Last_Updated_By,
    P_Last_Update_Date               => P_Last_Update_Date,
    P_Item_Id                        => P_Item_Id,
    P_Rate_Context                   => P_Rate_Context,
    P_Location1_Rate                 => P_Location1_Rate,
    P_Location2_Rate                 => P_Location2_Rate,
    P_Location3_Rate                 => P_Location3_Rate,
    P_Location4_Rate                 => P_Location4_Rate,
    P_Location5_Rate                 => P_Location5_Rate,
    P_Location6_Rate                 => P_Location6_Rate,
    P_Location7_Rate                 => P_Location7_Rate,
    P_Location8_Rate                 => P_Location8_Rate,
    P_Location9_Rate                 => P_Location9_Rate,
    P_Location10_Rate                => P_Location10_Rate,
    P_Start_Date                     => P_Start_Date,
    P_End_Date                       => P_End_Date,
    P_Attribute_Category             => P_Attribute_Category,
    P_Attribute1                     => P_Attribute1,
    P_Attribute2                     => P_Attribute2,
    P_Attribute3                     => P_Attribute3,
    P_Attribute4                     => P_Attribute4,
    P_Attribute5                     => P_Attribute5,
    P_Attribute6                     => P_Attribute6,
    P_Attribute7                     => P_Attribute7,
    P_Attribute8                     => P_Attribute8,
    P_Attribute9                     => P_Attribute9,
    P_Attribute10                    => P_Attribute10,
    P_Attribute11                    => P_Attribute11,
    P_Attribute12                    => P_Attribute12,
    P_Attribute13                    => P_Attribute13,
    P_Attribute14                    => P_Attribute14,
    P_Attribute15                    => P_Attribute15,
    P_Reason_Code                    => P_Reason_Code,
    P_Location_Context               => P_Location_Context,
    P_Location_Id_Segment_1          => P_Location_Id_Segment_1,
    P_Location_Id_Segment_2          => P_Location_Id_Segment_2,
    P_Location_Id_Segment_3          => P_Location_Id_Segment_3,
    P_Location_Id_Segment_4          => P_Location_Id_Segment_4,
    P_Location_Id_Segment_5          => P_Location_Id_Segment_5,
    P_Location_Id_Segment_6          => P_Location_Id_Segment_6,
    P_Location_Id_Segment_7          => P_Location_Id_Segment_7,
    P_Location_Id_Segment_8          => P_Location_Id_Segment_8,
    P_Location_Id_Segment_9          => P_Location_Id_Segment_9,
    P_Location_Id_Segment_10         => P_Location_Id_Segment_10
    );


  END Update_Row;


  PROCEDURE Delete_Row(p_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM RA_ITEM_EXCEPTION_RATES
    WHERE rowid = p_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END ARP_IER_PKG;

/
