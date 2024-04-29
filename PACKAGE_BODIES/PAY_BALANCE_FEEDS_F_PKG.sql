--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_FEEDS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_FEEDS_F_PKG" as
/* $Header: pyblf01t.pkb 120.0 2005/05/29 03:19 appldev noship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_balance_feeds_f_pkg
  Purpose
    Used by PAYWSDBT (Define Balance Type) for the balance feeds block (BLF).
  Notes

  History
    01-Mar-94  J.S.Hobbs   40.0         Date created.
    20-Apr-94  J.S.Hobbs   40.1         Added rtrim to Lock_Row.
    16-Jan-95  N Simpson   40.2	        Added code to handle AOL Who columns
					as per set 8 Changes 40.0
    01-Feb-95  J.S.Hobbs   40.4         Removed aol WHO columns.
    24-Apr-95  J.S.Hobbs   40.5         Added extra validation to stop the
					mixing of manual and automatic balance
					feeds (via classifications).
    19-Jul-95  D.Kerr	   40.6		Changes to support initial balance
					upload.
    02-Oct-95  D.Kerr	   40.7		310643 : overloads for insert_row,
					update_row and delete_row
    05-Mar-97  J.Alloun    40.8         Changed all occurances of system.dual
                                        to sys.dual for next release requirements.
    08-Dec-03  T.Habara    115.1        Bug 3285363. Modified cursor C3 in
                                        insert_row().
                                        Added commit, dbdrv, whenever oserror.
                                        Added nocopy changes.
    26-APR-04  A.Logue     115.2        Performance fix to C1 in
                                        check_run_result_usage.
 ============================================================================*/
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a balance feed    --
 --   via the Define Balance Type form.                                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Balance_Feed_Id              IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2 ) IS
 BEGIN
   Insert_Row(X_Rowid                 => X_Rowid,
              X_Balance_Feed_Id       => X_Balance_Feed_Id,
              X_Effective_Start_Date  => X_Effective_Start_Date,
              X_Effective_End_Date    => X_Effective_End_Date,
              X_Business_Group_Id     => X_Business_Group_Id,
              X_Legislation_Code      => X_Legislation_Code,
              X_Balance_Type_Id       => X_Balance_Type_Id ,
              X_Input_Value_Id        => X_Input_Value_Id,
              X_Scale                 => X_Scale,
              X_Legislation_Subgroup  => X_Legislation_Subgroup  ,
	      X_Initial_Balance_Feed  => FALSE ) ;
 END Insert_Row;
 --
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Balance_Feed_Id              IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2,
		      X_Initial_Balance_Feed                BOOLEAN ) IS
   --
   l_balance_feed_id   number:= X_Balance_Feed_Id;
   CURSOR C IS SELECT rowid FROM pay_balance_feeds_f
               WHERE  balance_feed_id = l_balance_feed_id;
   --
   CURSOR C2 IS SELECT pay_balance_feeds_s.nextval FROM sys.dual;
   --
   -- Bug 3285363.
   -- Modified cursor C3 to select only those initial feed elements
   -- that are available in the business group/legislation.
   --
   l_legislation_code  varchar2(30)
     := nvl(X_Legislation_Code
           ,hr_api.return_legislation_code(X_Business_Group_Id));
   --
   CURSOR C3 IS SELECT 'Y'
		FROM   pay_balance_feeds_f         blf,
		       pay_input_values_f          inv,
		       pay_element_types_f         elt,
		       pay_element_classifications ec
		WHERE  blf.balance_type_id   = X_Balance_Type_Id
		AND    blf.input_value_id    = inv.input_value_id
		AND    inv.element_type_id   = elt.element_type_id
		AND    nvl(elt.legislation_code
		          ,nvl(l_legislation_code, '~nvl~'))
		         = nvl(l_legislation_code, '~nvl~')
		AND    nvl(elt.business_group_id
		          ,nvl(X_Business_Group_Id, -1))
		         = nvl(X_Business_Group_Id, -1)
		AND    elt.classification_id = ec.classification_id
		AND    ec.balance_initialization_flag = 'Y';

   --
   l_found_initial_balance_feed varchar2(1) := 'N' ;  -- Is there another init.
					              -- bal. feed for this
						      -- element ?
 BEGIN
   --
   -- Lock balance type to stop other users changing the balance feed.
   --
   hr_balance_feeds.lock_balance_type(X_Balance_Type_Id);
   --
   --
   --
   -- Make sure that balance is not fed by classifications which would make the
   -- balance feeds READ-ONLY and therefore this operation invalid.
   --
   if ( not X_Initial_Balance_Feed )
   then
   --
     if ( hr_balance_feeds.bal_classifications_exist(X_Balance_Type_Id))
     then
        hr_utility.set_message(801, 'HR_7444_BAL_FEED_READ_ONLY');
        hr_utility.raise_error;
     end if;
   --
   else
   --
     --
     -- Make sure that there is only a single initial balance feed
     --
     OPEN C3 ;
     FETCH C3 into l_found_initial_balance_feed ;
     CLOSE C3 ;
     --
     if ( l_found_initial_balance_feed = 'Y' ) then
        hr_utility.set_message(801,'HR_7875_BAL_FEED_HAS_INIT_FEED');
        hr_utility.raise_error;
     end if;
     --
     --
     -- Make sure that there are no processed run results for this input
     -- value.
     --
     check_run_result_usage( X_Input_Value_Id ) ;
     --
   end if;
   --
   --
   if (l_balance_feed_id is NULL) then
     OPEN C2;
     FETCH C2 INTO l_balance_feed_id;
     CLOSE C2;
   end if;
   --
   INSERT INTO pay_balance_feeds_f
   (balance_feed_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    legislation_code,
    balance_type_id,
    input_value_id,
    scale,
    legislation_subgroup)
   VALUES
   (l_balance_feed_id,
    X_Effective_Start_Date,
    X_Effective_End_Date,
    X_Business_Group_Id,
    X_Legislation_Code,
    X_Balance_Type_Id,
    X_Input_Value_Id,
    X_Scale,
    X_Legislation_Subgroup);
   --
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_feeds_f_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
   X_Balance_Feed_Id := l_balance_feed_id;
   --
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a balance feed by applying a lock on a balance feed in the Define  --
 --   Balance Type form.                                                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Balance_Feed_Id                       NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Input_Value_Id                        NUMBER,
                    X_Scale                                 NUMBER,
                    X_Legislation_Subgroup                  VARCHAR2) IS
   --
   CURSOR C IS SELECT * FROM pay_balance_feeds_f
               WHERE  rowid = X_Rowid FOR UPDATE of Balance_Feed_Id NOWAIT;
   --
   Recinfo C%ROWTYPE;
   --
 BEGIN
   --
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_feeds_f_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
   --
   -- Remove trailing spaces.
   --
   Recinfo.legislation_code := rtrim(Recinfo.legislation_code);
   Recinfo.legislation_subgroup := rtrim(Recinfo.legislation_subgroup);
   --
   if (    (   (Recinfo.balance_feed_id = X_Balance_Feed_Id)
            OR (    (Recinfo.balance_feed_id IS NULL)
                AND (X_Balance_Feed_Id IS NULL)))
       AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
            OR (    (Recinfo.effective_start_date IS NULL)
                AND (X_Effective_Start_Date IS NULL)))
       AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
            OR (    (Recinfo.effective_end_date IS NULL)
                AND (X_Effective_End_Date IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.legislation_code = X_Legislation_Code)
            OR (    (Recinfo.legislation_code IS NULL)
                AND (X_Legislation_Code IS NULL)))
       AND (   (Recinfo.balance_type_id = X_Balance_Type_Id)
            OR (    (Recinfo.balance_type_id IS NULL)
                AND (X_Balance_Type_Id IS NULL)))
       AND (   (Recinfo.input_value_id = X_Input_Value_Id)
            OR (    (Recinfo.input_value_id IS NULL)
                AND (X_Input_Value_Id IS NULL)))
       AND (   (Recinfo.scale = X_Scale)
            OR (    (Recinfo.scale IS NULL)
                AND (X_Scale IS NULL)))
       AND (   (Recinfo.legislation_subgroup = X_Legislation_Subgroup)
            OR (    (Recinfo.legislation_subgroup IS NULL)
                AND (X_Legislation_Subgroup IS NULL)))
           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
   --
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a balance feed    --
 --   via the Define Balance Type form.                                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Feed_Id                     NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2 ) IS
 BEGIN
    Update_Row(X_Rowid                => X_Rowid,
               X_Balance_Feed_Id      => X_Balance_Feed_Id,
               X_Effective_Start_Date => X_Effective_Start_Date,
               X_Effective_End_Date   => X_Effective_End_Date,
               X_Business_Group_Id    => X_Business_Group_Id,
               X_Legislation_Code     => X_Legislation_Code,
               X_Balance_Type_Id      => X_Balance_Type_Id,
               X_Input_Value_Id       => X_Input_Value_Id,
               X_Scale                => X_Scale,
               X_Legislation_Subgroup => X_Legislation_Subgroup,
	       X_Initial_Balance_Feed => FALSE );
 END Update_Row ;
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Feed_Id                     NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2,
		      X_Initial_Balance_Feed		    BOOLEAN) IS
 BEGIN
   --
   -- Lock balance type to stop other users changing the balance feed.
   --
   hr_balance_feeds.lock_balance_type(X_Balance_Type_Id);
   --
   -- Make sure that balance is not fed by classifications which would make the
   -- balance feeds READ-ONLY and therefore this operation invalid.
   --
   if ( NOT X_initial_Balance_Feed )
   then
   --
	if ( hr_balance_feeds.bal_classifications_exist(X_Balance_Type_Id))
	then
            hr_utility.set_message(801, 'HR_7444_BAL_FEED_READ_ONLY');
            hr_utility.raise_error;
	end if;
   --
   else
	--
        -- Make sure that there are no processed run results for this
	-- input value
	--
        check_run_result_usage( X_Input_Value_Id ) ;
	--
   end if;
   --
   UPDATE pay_balance_feeds_f
   SET balance_feed_id          =    X_Balance_Feed_Id,
       effective_start_date     =    X_Effective_Start_Date,
       effective_end_date       =    X_Effective_End_Date,
       business_group_id        =    X_Business_Group_Id,
       legislation_code         =    X_Legislation_Code,
       balance_type_id          =    X_Balance_Type_Id,
       input_value_id           =    X_Input_Value_Id,
       scale                    =    X_Scale,
       legislation_subgroup     =    X_Legislation_Subgroup
   WHERE rowid = X_rowid;
   --
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_feeds_f_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   --
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a balance feed    --
 --   via the Define Balance Type form.                                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                VARCHAR2,
		      -- Extra Columns
		      X_Balance_Type_Id      NUMBER ) IS
 BEGIN
   Delete_Row(X_Rowid                => X_Rowid,
	      X_Balance_Type_Id      => X_Balance_Type_Id,
	      X_Input_Value_Id       => NULL,
	      X_Initial_Balance_Feed => FALSE ) ;
 END Delete_Row;
 --
 PROCEDURE Delete_Row(X_Rowid                VARCHAR2,
		      -- Extra Columns
		      X_Balance_Type_Id      NUMBER,
		      X_Input_Value_Id       NUMBER,
		      X_Initial_Balance_Feed BOOLEAN) IS
 BEGIN
   --
   -- Lock balance type to stop other users changing the balance feed.
   --
   hr_balance_feeds.lock_balance_type(X_Balance_Type_Id);
   --
   -- Make sure that balance is not fed by classifications which would make the
   -- balance feeds READ-ONLY and therefore this operation invalid.
   --
   if ( NOT X_Initial_Balance_Feed ) then
   --
     if hr_balance_feeds.bal_classifications_exist(X_Balance_Type_Id) then
        hr_utility.set_message(801, 'HR_7444_BAL_FEED_READ_ONLY');
        hr_utility.raise_error;
     end if;
   --
   else
	--
        -- Make sure that there are no processed run results for this
	-- input value
	--
        check_run_result_usage( X_Input_Value_Id ) ;
	--
   end if;
   --
   DELETE FROM pay_balance_feeds_f
   WHERE  rowid = X_Rowid;
   --
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_feeds_f_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   --
 END Delete_Row;
--
 FUNCTION  check_run_result_usage ( X_Input_Value_Id  IN NUMBER )
				     RETURN BOOLEAN IS
 CURSOR C1 IS SELECT 1
	      FROM   pay_run_result_values rrv
	      WHERE  rrv.input_value_id  = X_Input_Value_Id ;
 l_dummy        NUMBER ;
 l_return_value BOOLEAN ;
 BEGIN
 --
     OPEN C1 ;
     FETCH C1 INTO l_dummy ;
     IF    C1%FOUND THEN
           hr_utility.set_message(801,'HR_7876_BAL_FEED_RESULTS_EXIST');
	   l_return_value := FALSE ;
     ELSE
	   l_return_value := TRUE  ;
     END IF;
 --
     CLOSE C1 ;
 --
     return ( l_return_value ) ;
 --
 END check_run_result_usage ;
 PROCEDURE  check_run_result_usage ( X_Input_Value_Id  IN NUMBER ) IS
 BEGIN
 --
    IF ( NOT check_run_result_usage ( X_Input_Value_Id ) ) THEN
      hr_utility.raise_error ;
    END IF;
 --
 END check_run_result_usage ;
--
END PAY_BALANCE_FEEDS_F_PKG;

/
