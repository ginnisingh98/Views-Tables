--------------------------------------------------------
--  DDL for Package Body FA_MASS_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_RET_PKG" as
/* $Header: faxmreb.pls 120.29.12010000.6 2010/01/19 11:54:32 bmaddine ship $ */

   g_release                  number  := fa_cache_pkg.fazarel_release;

   -- Global Variables holding Mass Retirements Information
   G_Mass_Retirement_Id            fa_mass_retirements.Mass_Retirement_Id%TYPE;
   G_Book_Type_Code                fa_mass_retirements.Book_Type_Code%TYPE;
   G_Retire_Subcomponents          fa_mass_retirements.Retire_Subcomponents_Flag%TYPE;
   G_Status                        fa_mass_retirements.Status%TYPE;
   G_Retire_Request_Id             fa_mass_retirements.Retire_Request_Id%TYPE;
   G_Retirement_Date               fa_mass_retirements.Retirement_Date%TYPE;
   G_Proceeds_Of_Sale              fa_mass_retirements.Proceeds_Of_Sale%TYPE;
   G_Cost_Of_Removal               fa_mass_retirements.Cost_Of_Removal%TYPE;
   G_Transaction_Name              fa_mass_retirements.Description%TYPE;
   G_Retirement_Type_Code          fa_mass_retirements.Retirement_Type_Code%TYPE;
   G_Asset_Type                    fa_mass_retirements.Asset_Type%TYPE;
   G_Location_Id                   fa_mass_retirements.Location_Id%TYPE;
   G_Employee_Id                   fa_mass_retirements.Employee_Id%TYPE;
   G_Category_Id                   fa_mass_retirements.Category_Id%TYPE;
   G_Asset_Key_Id                  fa_mass_retirements.Asset_Key_Id%TYPE;
   G_From_Asset_Number             fa_mass_retirements.From_Asset_Number%TYPE;
   G_To_Asset_Number               fa_mass_retirements.To_Asset_Number%TYPE;
   G_From_DPIS                     fa_mass_retirements.From_Date_Placed_In_Service%TYPE;
   G_To_DPIS                       fa_mass_retirements.To_Date_Placed_In_Service%TYPE;
   G_Created_By                    fa_mass_retirements.Created_By%TYPE;
--   G_Last_Update_Login             fa_mass_retirements.Last_Update_Login%TYPE;
   G_From_Cost                     fa_mass_retirements.from_cost%TYPE;
   G_To_Cost                       fa_mass_retirements.to_cost%TYPE;
   G_Fully_Rsvd_Flag               fa_mass_retirements.include_fully_rsvd_flag%TYPE;
   G_model_number                  fa_mass_retirements.model_number%TYPE;
   G_serial_number                 fa_mass_retirements.serial_number%TYPE;
   G_tag_number                    fa_mass_retirements.tag_number%TYPE;
   G_manufacturer_name             fa_mass_retirements.manufacturer_name%TYPE;
   G_units                         fa_mass_retirements.units_to_retire%TYPE;
   G_Attribute1                    fa_mass_retirements.attribute1%TYPE;
   G_Attribute2                    fa_mass_retirements.attribute2%TYPE;
   G_Attribute3                    fa_mass_retirements.attribute3%TYPE;
   G_Attribute4                    fa_mass_retirements.attribute4%TYPE;
   G_Attribute5                    fa_mass_retirements.attribute5%TYPE;
   G_Attribute6                    fa_mass_retirements.attribute6%TYPE;
   G_Attribute7                    fa_mass_retirements.attribute7%TYPE;
   G_Attribute8                    fa_mass_retirements.attribute8%TYPE;
   G_Attribute9                    fa_mass_retirements.attribute9%TYPE;
   G_Attribute10                   fa_mass_retirements.attribute10%TYPE;
   G_Attribute11                   fa_mass_retirements.attribute11%TYPE;
   G_Attribute12                   fa_mass_retirements.attribute12%TYPE;
   G_Attribute13                   fa_mass_retirements.attribute13%TYPE;
   G_Attribute14                   fa_mass_retirements.attribute14%TYPE;
   G_Attribute15                   fa_mass_retirements.attribute15%TYPE;
   G_Attribute_category_code       fa_mass_retirements.attribute_category_code%TYPE;
   G_Segment1_Low                  fa_mass_retirements.segment1_low%TYPE;
   G_Segment2_Low                  fa_mass_retirements.segment2_low%TYPE;
   G_Segment3_Low                  fa_mass_retirements.segment3_low%TYPE;
   G_Segment4_Low                  fa_mass_retirements.segment4_low%TYPE;
   G_Segment5_Low                  fa_mass_retirements.segment5_low%TYPE;
   G_Segment6_Low                  fa_mass_retirements.segment6_low%TYPE;
   G_Segment7_Low                  fa_mass_retirements.segment7_low%TYPE;
   G_Segment8_Low                  fa_mass_retirements.segment8_low%TYPE;
   G_Segment9_Low                  fa_mass_retirements.segment9_low%TYPE;
   G_Segment10_Low                 fa_mass_retirements.segment10_low%TYPE;
   G_Segment11_Low                 fa_mass_retirements.segment11_low%TYPE;
   G_Segment12_Low                 fa_mass_retirements.segment12_low%TYPE;
   G_Segment13_Low                 fa_mass_retirements.segment13_low%TYPE;
   G_Segment14_Low                 fa_mass_retirements.segment14_low%TYPE;
   G_Segment15_Low                 fa_mass_retirements.segment15_low%TYPE;
   G_Segment16_Low                 fa_mass_retirements.segment16_low%TYPE;
   G_Segment17_Low                 fa_mass_retirements.segment17_low%TYPE;
   G_Segment18_Low                 fa_mass_retirements.segment18_low%TYPE;
   G_Segment19_Low                 fa_mass_retirements.segment19_low%TYPE;
   G_Segment20_Low                 fa_mass_retirements.segment20_low%TYPE;
   G_Segment21_Low                 fa_mass_retirements.segment21_low%TYPE;
   G_Segment22_Low                 fa_mass_retirements.segment22_low%TYPE;
   G_Segment23_Low                 fa_mass_retirements.segment23_low%TYPE;
   G_Segment24_Low                 fa_mass_retirements.segment24_low%TYPE;
   G_Segment25_Low                 fa_mass_retirements.segment25_low%TYPE;
   G_Segment26_Low                 fa_mass_retirements.segment26_low%TYPE;
   G_Segment27_Low                 fa_mass_retirements.segment27_low%TYPE;
   G_Segment28_Low                 fa_mass_retirements.segment28_low%TYPE;
   G_Segment29_Low                 fa_mass_retirements.segment29_low%TYPE;
   G_Segment30_Low                 fa_mass_retirements.segment30_low%TYPE;
   G_Segment1_High                 fa_mass_retirements.segment1_high%TYPE;
   G_Segment2_High                 fa_mass_retirements.segment2_high%TYPE;
   G_Segment3_High                 fa_mass_retirements.segment3_high%TYPE;
   G_Segment4_High                 fa_mass_retirements.segment4_high%TYPE;
   G_Segment5_High                 fa_mass_retirements.segment5_high%TYPE;
   G_Segment6_High                 fa_mass_retirements.segment6_high%TYPE;
   G_Segment7_High                 fa_mass_retirements.segment7_high%TYPE;
   G_Segment8_High                 fa_mass_retirements.segment8_high%TYPE;
   G_Segment9_High                 fa_mass_retirements.segment9_high%TYPE;
   G_Segment10_High                fa_mass_retirements.segment10_high%TYPE;
   G_Segment11_High                fa_mass_retirements.segment11_high%TYPE;
   G_Segment12_High                fa_mass_retirements.segment12_high%TYPE;
   G_Segment13_High                fa_mass_retirements.segment13_high%TYPE;
   G_Segment14_High                fa_mass_retirements.segment14_high%TYPE;
   G_Segment15_High                fa_mass_retirements.segment15_high%TYPE;
   G_Segment16_High                fa_mass_retirements.segment16_high%TYPE;
   G_Segment17_High                fa_mass_retirements.segment17_high%TYPE;
   G_Segment18_High                fa_mass_retirements.segment18_high%TYPE;
   G_Segment19_High                fa_mass_retirements.segment19_high%TYPE;
   G_Segment20_High                fa_mass_retirements.segment20_high%TYPE;
   G_Segment21_High                fa_mass_retirements.segment21_high%TYPE;
   G_Segment22_High                fa_mass_retirements.segment22_high%TYPE;
   G_Segment23_High                fa_mass_retirements.segment23_high%TYPE;
   G_Segment24_High                fa_mass_retirements.segment24_high%TYPE;
   G_Segment25_High                fa_mass_retirements.segment25_high%TYPE;
   G_Segment26_High                fa_mass_retirements.segment26_high%TYPE;
   G_Segment27_High                fa_mass_retirements.segment27_high%TYPE;
   G_Segment28_High                fa_mass_retirements.segment28_high%TYPE;
   G_Segment29_High                fa_mass_retirements.segment29_high%TYPE;
   G_Segment30_High                fa_mass_retirements.segment30_high%TYPE;


   G_Extend_Search        VARCHAR2(10);
   G_Mode                 VARCHAR2(30);
   G_batch_name           VARCHAR2(30);
   G_Book_Class           fa_book_controls.book_class%TYPE;
   G_Currency_Code        gl_sets_of_books.currency_code%TYPE;
   G_Precision            NUMBER;
   G_Ext_Precision        NUMBER;
   G_Min_Acct_Unit        NUMBER;
   G_Tax_Cost             NUMBER;
   G_Today_Datetime                DATE;
   G_Today_Date                    DATE;
   G_Varchar2_Dummy                VARCHAR2(80);
   G_Number_Dummy                  NUMBER(15);
   G_Mass_Reference_Id             NUMBER(15);

   -- mwoodwar 01/18/00.  Variable for CRL.
   G_Group_Asset_Id                NUMBER;
   G_Group_Association             VARCHAR2(30);
-- who info
   G_last_updated_by    number := FND_GLOBAL.USER_ID;
   G_last_update_login  number := FND_GLOBAL.CONC_LOGIN_ID;


   g_log_level_rec fa_api_types.log_level_rec_type;
------------------------------------------------------------------------------
l_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE Acct_Split(X_1st_Segment     IN               VARCHAR2,
                     X_Current_Segment IN               VARCHAR2,
                     X_Acct_Split      IN OUT NOCOPY    VARCHAR2) IS

   l_Acct_Split VARCHAR2(1);

BEGIN

   IF X_Acct_Split = 'Y' THEN
      l_Acct_Split := X_Acct_Split;
   ELSE
      IF (X_1st_Segment IS NULL
          AND X_Current_Segment IS NOT NULL) THEN
         l_Acct_Split := 'Y';
      ELSIF (X_1st_Segment IS NOT NULL
          AND X_Current_Segment IS NULL) THEN
         l_Acct_Split := 'Y';
      ELSIF X_1st_Segment <> X_Current_Segment THEN
         l_Acct_Split := 'Y';
      ELSE
         l_Acct_Split := 'N';
      END IF;
   END IF;

   X_Acct_Split :=  l_Acct_Split;

END Acct_Split;
------------------------------------------------------------------------------

-- CHECK_TAX_SPLIT IS ONLY FOR TAX BOOKS.
-- Checks to see if an asset assigned to more than one employee.
-- Checks to see if an asset is partially assigned to one or more
-- employees .
-- Checks to see if asset assigned to one or more accounts or
-- one or more locations.
PROCEDURE Check_Tax_Split(X_Asset_Id    IN  NUMBER,
                          X_Emp_Split   OUT NOCOPY VARCHAR2,
                          X_Acct_Split  OUT NOCOPY VARCHAR2,
                          X_Loc_Split   OUT NOCOPY VARCHAR2) IS

   l_1st_Employee_Id     NUMBER(15);
   l_1st_Location_Id     NUMBER(15);

   l_Employee_Id         NUMBER(15);
   l_Location_Id         NUMBER(15);

   l_Acct_Split          VARCHAR2(1);
   l_Emp_Split           VARCHAR2(1);
   l_Loc_Split           VARCHAR2(1);

   l_1st_Segment1        gl_code_combinations.segment1%TYPE;
   l_1st_Segment2        gl_code_combinations.segment2%TYPE;
   l_1st_Segment3        gl_code_combinations.segment3%TYPE;
   l_1st_Segment4        gl_code_combinations.segment4%TYPE;
   l_1st_Segment5        gl_code_combinations.segment5%TYPE;
   l_1st_Segment6        gl_code_combinations.segment6%TYPE;
   l_1st_Segment7        gl_code_combinations.segment7%TYPE;
   l_1st_Segment8        gl_code_combinations.segment8%TYPE;
   l_1st_Segment9        gl_code_combinations.segment9%TYPE;
   l_1st_Segment10       gl_code_combinations.segment10%TYPE;
   l_1st_Segment11       gl_code_combinations.segment11%TYPE;
   l_1st_Segment12       gl_code_combinations.segment12%TYPE;
   l_1st_Segment13       gl_code_combinations.segment13%TYPE;
   l_1st_Segment14       gl_code_combinations.segment14%TYPE;
   l_1st_Segment15       gl_code_combinations.segment15%TYPE;
   l_1st_Segment16       gl_code_combinations.segment16%TYPE;
   l_1st_Segment17       gl_code_combinations.segment17%TYPE;
   l_1st_Segment18       gl_code_combinations.segment18%TYPE;
   l_1st_Segment19       gl_code_combinations.segment19%TYPE;
   l_1st_Segment20       gl_code_combinations.segment20%TYPE;
   l_1st_Segment21       gl_code_combinations.segment21%TYPE;
   l_1st_Segment22       gl_code_combinations.segment22%TYPE;
   l_1st_Segment23       gl_code_combinations.segment23%TYPE;
   l_1st_Segment24       gl_code_combinations.segment24%TYPE;
   l_1st_Segment25       gl_code_combinations.segment25%TYPE;
   l_1st_Segment26       gl_code_combinations.segment26%TYPE;
   l_1st_Segment27       gl_code_combinations.segment27%TYPE;
   l_1st_Segment28       gl_code_combinations.segment28%TYPE;
   l_1st_Segment29       gl_code_combinations.segment29%TYPE;
   l_1st_Segment30       gl_code_combinations.segment30%TYPE;

   l_Segment1            gl_code_combinations.segment1%TYPE;
   l_Segment2            gl_code_combinations.segment2%TYPE;
   l_Segment3            gl_code_combinations.segment3%TYPE;
   l_Segment4            gl_code_combinations.segment4%TYPE;
   l_Segment5            gl_code_combinations.segment5%TYPE;
   l_Segment6            gl_code_combinations.segment6%TYPE;
   l_Segment7            gl_code_combinations.segment7%TYPE;
   l_Segment8            gl_code_combinations.segment8%TYPE;
   l_Segment9            gl_code_combinations.segment9%TYPE;
   l_Segment10           gl_code_combinations.segment10%TYPE;
   l_Segment11           gl_code_combinations.segment11%TYPE;
   l_Segment12           gl_code_combinations.segment12%TYPE;
   l_Segment13           gl_code_combinations.segment13%TYPE;
   l_Segment14           gl_code_combinations.segment14%TYPE;
   l_Segment15           gl_code_combinations.segment15%TYPE;
   l_Segment16           gl_code_combinations.segment16%TYPE;
   l_Segment17           gl_code_combinations.segment17%TYPE;
   l_Segment18           gl_code_combinations.segment18%TYPE;
   l_Segment19           gl_code_combinations.segment19%TYPE;
   l_Segment20           gl_code_combinations.segment20%TYPE;
   l_Segment21           gl_code_combinations.segment21%TYPE;
   l_Segment22           gl_code_combinations.segment22%TYPE;
   l_Segment23           gl_code_combinations.segment23%TYPE;
   l_Segment24           gl_code_combinations.segment24%TYPE;
   l_Segment25           gl_code_combinations.segment25%TYPE;
   l_Segment26           gl_code_combinations.segment26%TYPE;
   l_Segment27           gl_code_combinations.segment27%TYPE;
   l_Segment28           gl_code_combinations.segment28%TYPE;
   l_Segment29           gl_code_combinations.segment29%TYPE;
   l_Segment30           gl_code_combinations.segment30%TYPE;

   CURSOR multiple_distributions IS
   SELECT fdh.assigned_to,
          fdh.location_id,
          gcc.segment1,           gcc.segment2,
          gcc.segment3,           gcc.segment4,
          gcc.segment5,           gcc.segment6,
          gcc.segment7,           gcc.segment8,
          gcc.segment9,           gcc.segment10,
          gcc.segment11,          gcc.segment12,
          gcc.segment13,          gcc.segment14,
          gcc.segment15,          gcc.segment16,
          gcc.segment17,          gcc.segment18,
          gcc.segment19,          gcc.segment20,
          gcc.segment21,          gcc.segment22,
          gcc.segment23,          gcc.segment24,
          gcc.segment25,          gcc.segment26,
          gcc.segment27,          gcc.segment28,
          gcc.segment29,          gcc.segment30
     FROM fa_distribution_history fdh,
          gl_code_combinations    gcc
    WHERE fdh.asset_id             = X_Asset_Id
      AND fdh.code_combination_id  = gcc.code_combination_id
      AND fdh.date_ineffective    IS NULL;

BEGIN -- Check_Tax_Split

   l_Emp_Split   := 'N';
   l_Loc_Split   := 'N';
   l_Acct_Split  := 'N';

   OPEN multiple_distributions;
   LOOP
      FETCH multiple_distributions
       INTO l_Employee_Id,
            l_Location_Id,
            l_segment1,      l_segment2,
            l_segment3,      l_segment4,
            l_segment5,      l_segment6,
            l_segment7,      l_segment8,
            l_segment9,      l_segment10,
            l_segment11,     l_segment12,
            l_segment13,     l_segment14,
            l_segment15,     l_segment16,
            l_segment17,     l_segment18,
            l_segment19,     l_segment20,
            l_segment21,     l_segment22,
            l_segment23,     l_segment24,
            l_segment25,     l_segment26,
            l_segment27,     l_segment28,
            l_segment29,     l_segment30;
      EXIT WHEN multiple_distributions%NOTFOUND;

      IF multiple_distributions%ROWCOUNT = 1 THEN
         l_1st_Employee_Id := l_Employee_Id;
         l_1st_Location_Id := l_Location_Id;
         l_1st_Segment1    := l_Segment1;
         l_1st_Segment2    := l_Segment2;
         l_1st_Segment3    := l_Segment3;
         l_1st_Segment4    := l_Segment4;
         l_1st_Segment5    := l_Segment5;
         l_1st_Segment6    := l_Segment6;
         l_1st_Segment7    := l_Segment7;
         l_1st_Segment8    := l_Segment8;
         l_1st_Segment9    := l_Segment9;
         l_1st_Segment10   := l_Segment10;
         l_1st_Segment11   := l_Segment11;
         l_1st_Segment12   := l_Segment12;
         l_1st_Segment13   := l_Segment13;
         l_1st_Segment14   := l_Segment14;
         l_1st_Segment15   := l_Segment15;
         l_1st_Segment16   := l_Segment16;
         l_1st_Segment17   := l_Segment17;
         l_1st_Segment18   := l_Segment18;
         l_1st_Segment19   := l_Segment19;
         l_1st_Segment20   := l_Segment20;
         l_1st_Segment21   := l_Segment21;
         l_1st_Segment22   := l_Segment22;
         l_1st_Segment23   := l_Segment23;
         l_1st_Segment24   := l_Segment24;
         l_1st_Segment25   := l_Segment25;
         l_1st_Segment26   := l_Segment26;
         l_1st_Segment27   := l_Segment27;
         l_1st_Segment28   := l_Segment28;
         l_1st_Segment29   := l_Segment29;
         l_1st_Segment30   := l_Segment30;
      ELSE
         IF (l_1st_Employee_Id IS NULL AND
             l_Employee_Id IS NOT NULL) THEN
            l_Emp_Split := 'Y';
         ELSIF (l_1st_Employee_Id IS NOT NULL AND
                l_Employee_Id IS NULL) THEN
            l_Emp_Split := 'Y';
         ELSIF l_1st_Employee_Id <> l_Employee_Id THEN
            l_Emp_Split := 'Y';
         END IF;

         IF l_1st_Location_Id <> l_Location_Id THEN
            l_Loc_Split := 'Y';
         END IF;

      END IF;


      Acct_Split(l_1st_Segment1, l_Segment1,l_Acct_Split);
      Acct_Split(l_1st_Segment2, l_Segment2,l_Acct_Split);
      Acct_Split(l_1st_Segment3, l_Segment3,l_Acct_Split);
      Acct_Split(l_1st_Segment4, l_Segment4,l_Acct_Split);
      Acct_Split(l_1st_Segment5, l_Segment5,l_Acct_Split);
      Acct_Split(l_1st_Segment6, l_Segment6,l_Acct_Split);
      Acct_Split(l_1st_Segment7, l_Segment7,l_Acct_Split);
      Acct_Split(l_1st_Segment8, l_Segment8,l_Acct_Split);
      Acct_Split(l_1st_Segment9, l_Segment9,l_Acct_Split);
      Acct_Split(l_1st_Segment10,l_Segment10,l_Acct_Split);
      Acct_Split(l_1st_Segment11,l_Segment11,l_Acct_Split);
      Acct_Split(l_1st_Segment12,l_Segment12,l_Acct_Split);
      Acct_Split(l_1st_Segment13,l_Segment13,l_Acct_Split);
      Acct_Split(l_1st_Segment14,l_Segment14,l_Acct_Split);
      Acct_Split(l_1st_Segment15,l_Segment15,l_Acct_Split);
      Acct_Split(l_1st_Segment16,l_Segment16,l_Acct_Split);
      Acct_Split(l_1st_Segment17,l_Segment17,l_Acct_Split);
      Acct_Split(l_1st_Segment18,l_Segment18,l_Acct_Split);
      Acct_Split(l_1st_Segment19,l_Segment19,l_Acct_Split);
      Acct_Split(l_1st_Segment20,l_Segment20,l_Acct_Split);
      Acct_Split(l_1st_Segment21,l_Segment21,l_Acct_Split);
      Acct_Split(l_1st_Segment22,l_Segment22,l_Acct_Split);
      Acct_Split(l_1st_Segment23,l_Segment23,l_Acct_Split);
      Acct_Split(l_1st_Segment24,l_Segment24,l_Acct_Split);
      Acct_Split(l_1st_Segment25,l_Segment25,l_Acct_Split);
      Acct_Split(l_1st_Segment26,l_Segment26,l_Acct_Split);
      Acct_Split(l_1st_Segment27,l_Segment27,l_Acct_Split);
      Acct_Split(l_1st_Segment28,l_Segment28,l_Acct_Split);
      Acct_Split(l_1st_Segment29,l_Segment29,l_Acct_Split);
      Acct_Split(l_1st_Segment30,l_Segment30,l_Acct_Split);

   END LOOP; -- multiple_distributions

   X_Emp_Split   := l_Emp_Split;
   X_Loc_Split   := l_Loc_Split;
   X_Acct_Split  := l_Acct_Split;

END Check_Tax_Split;


------------------------------------------------------------------------------

FUNCTION Insert_details( p_asset_id                     IN NUMBER,
                         p_units_assigned               IN NUMBER,
                         p_code_combination_id          IN NUMBER,
                         p_location_id                  IN NUMBER,
                         p_assigned_to                  IN NUMBER,
                         p_cost                         IN NUMBER,
                         p_current_units                IN NUMBER)
                        RETURN BOOLEAN IS

  error         varchar2(100);
BEGIN

  insert into fa_mass_ext_retirements
             (batch_name,
              mass_external_retire_id,
              book_type_code,
              review_status,
              asset_id,
              calc_gain_loss_flag,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              cost_retired,
              cost_of_removal,
              proceeds_of_sale,
              retirement_type_code,
              date_retired,
              transaction_name,
              units,
              code_combination_id,
              location_id,
              assigned_to
              )
              VALUES
              (
              g_batch_name,
              fa_mass_ext_retirements_s.nextval,
              g_book_type_code,
              'POST',
              p_asset_id,
              'YES', -- calc_gain_loss_flag
              g_last_updated_by,
              sysdate,
              g_last_updated_by,
              sysdate,
              g_last_update_login,
              ((p_units_assigned / p_current_units) * p_cost),
              0,
              0,
              G_retirement_type_code,
              G_retirement_date,
              G_transaction_name,
              p_units_assigned,
              p_code_combination_id,
              p_location_id,
              p_assigned_to);


 return true;

EXCEPTION
  WHEN others THEN
      error := substrb(sqlerrm,1,80);
      fa_debug_pkg.add(
      'Insert_Details',
        error,
        '', p_log_level_rec => g_log_level_rec);
   return false;

END Insert_details;
------------------------------------------------------------------------------


FUNCTION Check_Split_Distribution(
                   X_Asset_Id           IN  NUMBER,
                   p_asset_dist_tbl     OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type)
                RETURN BOOLEAN IS


   l_code_combination_id fa_distribution_history.code_combination_id%TYPE;
   l_location_id         fa_distribution_history.location_id%TYPE;
   l_assigned_to         fa_distribution_history.assigned_to%TYPE;
   l_units_assigned      fa_distribution_history.units_assigned%TYPE;

   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;
   i                            NUMBER;
   l_check_account_null         VARCHAR2(1);


   Cursor c_cc is
    SELECT fad.code_combination_id,
           fad.location_id,
           fad.assigned_to,
           fad.units_assigned
    FROM fa_distribution_history fad,
         gl_code_combinations    gcc
    WHERE fad.asset_id = x_asset_id
    AND fad.date_ineffective IS NULL
    AND fad.code_combination_id = gcc.code_combination_id
    AND (fad.assigned_to = G_Employee_Id
                          OR G_Employee_Id IS NULL)
    AND (fad.location_id = G_Location_Id
                           OR G_Location_Id IS NULL)
    AND ((gcc.segment1 BETWEEN G_Segment1_Low
                          AND G_Segment1_High
                          OR G_Segment1_Low IS NULL)
    AND (gcc.segment2 BETWEEN G_Segment2_Low
                          AND G_Segment2_High
                          OR G_Segment2_Low IS NULL)
    AND (gcc.segment3 BETWEEN G_Segment3_Low
                          AND G_Segment3_High
                          OR G_Segment3_Low IS NULL)
    AND (gcc.segment4 BETWEEN G_Segment4_Low
                          AND G_Segment4_High
                          OR G_Segment4_Low IS NULL)
    AND (gcc.segment5 BETWEEN G_Segment5_Low
                          AND G_Segment5_High
                          OR G_Segment5_Low IS NULL)
    AND (gcc.segment6 BETWEEN G_Segment6_Low
                          AND G_Segment6_High
                          OR G_Segment6_Low IS NULL)
    AND (gcc.segment7 BETWEEN G_Segment7_Low
                          AND G_Segment7_High
                          OR G_Segment7_Low IS NULL)
    AND (gcc.segment8 BETWEEN G_Segment8_Low
                          AND G_Segment8_High
                          OR G_Segment8_Low IS NULL)
    AND (gcc.segment9 BETWEEN G_Segment9_Low
                          AND G_Segment9_High
                          OR G_Segment9_Low IS NULL)
    AND (gcc.segment10 BETWEEN G_Segment10_Low
                           AND G_Segment10_High
                           OR G_Segment10_Low IS NULL)
    AND (gcc.segment11 BETWEEN G_Segment11_Low
                           AND G_Segment11_High
                           OR G_Segment11_Low IS NULL)
    AND (gcc.segment12 BETWEEN G_Segment12_Low
                           AND G_Segment12_High
                           OR G_Segment12_Low IS NULL)
    AND (gcc.segment13 BETWEEN G_Segment13_Low
                           AND G_Segment13_High
                         OR G_Segment13_Low IS NULL)
    AND (gcc.segment14 BETWEEN G_Segment14_Low
                           AND G_Segment14_High
                           OR G_Segment14_Low IS NULL)
    AND (gcc.segment15 BETWEEN G_Segment15_Low
                           AND G_Segment15_High
                           OR G_Segment15_Low IS NULL)
    AND (gcc.segment16 BETWEEN G_Segment16_Low
                           AND G_Segment16_High
                           OR G_Segment16_Low IS NULL)
    AND (gcc.segment17 BETWEEN G_Segment17_Low
                           AND G_Segment17_High
                          OR G_Segment17_Low IS NULL)
    AND (gcc.segment18 BETWEEN G_Segment18_Low
                           AND G_Segment18_High
                          OR G_Segment18_Low IS NULL)
    AND (gcc.segment19 BETWEEN G_Segment19_Low
                           AND G_Segment19_High
                           OR G_segment19_Low IS NULL)
    AND (gcc.segment20 BETWEEN G_Segment20_Low
                           AND G_Segment20_High
                           OR G_segment20_Low IS NULL)
    AND (gcc.segment21 BETWEEN G_Segment21_Low
                           AND G_Segment21_High
                           OR G_segment21_Low IS NULL)
    AND (gcc.segment22 BETWEEN G_Segment22_Low
                           AND G_Segment22_High
                           OR G_segment22_Low IS NULL)
    AND (gcc.segment23 BETWEEN G_Segment23_Low
                           AND G_Segment23_High
                           OR G_segment23_Low IS NULL)
    AND (gcc.segment24 BETWEEN G_Segment24_Low
                           AND G_Segment24_High
                           OR G_segment24_Low IS NULL)
    AND (gcc.segment25 BETWEEN G_Segment25_Low
                           AND G_Segment25_High
                           OR G_segment25_Low IS NULL)
    AND (gcc.segment26 BETWEEN G_Segment26_Low
                           AND G_Segment26_High
                           OR G_segment26_Low IS NULL)
    AND (gcc.segment27 BETWEEN G_Segment27_Low
                           AND G_Segment27_High
                           OR G_segment27_Low IS NULL)
    AND (gcc.segment28 BETWEEN G_Segment28_Low
                           AND G_Segment28_High
                           OR G_segment28_Low IS NULL)
    And (gcc.segment29 BETWEEN G_Segment29_Low
                           AND G_Segment29_High
                           OR G_segment29_Low IS NULL)
    AND (gcc.segment30 BETWEEN G_Segment30_Low
                           AND G_Segment30_High
                           OR G_segment30_Low IS NULL)
    );



BEGIN -- Check_Split_Distribution

        if (g_log_level_rec.statement_level) then
              fa_debug_pkg.add('FA_MASS_RET_PKG.check_split...',
                                'Starting',
                                '', p_log_level_rec => g_log_level_rec);
        end if;


       i := 0;
       open c_cc;
       fetch c_cc into  l_code_combination_id,
                        l_location_id,
                        l_assigned_to,
                        l_units_assigned;
       While c_cc%FOUND loop

        if (g_log_level_rec.statement_level) then
              fa_debug_pkg.add('FA_MASS_RET_PKG.check_split...',
                                'Starting while loop turn:',
                                i, p_log_level_rec => g_log_level_rec);
        end if;

        i := i + 1;
        l_asset_dist_tbl(i).units_assigned      := l_units_assigned;
        l_asset_dist_tbl(i).expense_ccid        := l_code_combination_id;
        l_asset_dist_tbl(i).location_ccid       := l_location_id;
        l_asset_dist_tbl(i).assigned_to         := l_assigned_to;


        if (g_log_level_rec.statement_level) then
              fa_debug_pkg.add('FA_MASS_RET_PKG.check_split...',
                                'asset_id',
                                x_asset_id, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('FA_MASS_RET_PKG.check_split...',
                                'ccid',
                                l_code_combination_id, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('FA_MASS_RET_PKG.check_split...',
                                'location_id',
                                l_location_id, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('FA_MASS_RET_PKG.check_split...',
                                'assigned_to',
                                l_assigned_to, p_log_level_rec => g_log_level_rec);
        end if;

       fetch c_cc into  l_code_combination_id,
                        l_location_id,
                        l_assigned_to,
                        l_units_assigned;

       End loop;
       close c_cc;

       p_asset_dist_tbl := l_asset_dist_tbl;

       return true;
Exception
  When others then

    return false;

END Check_Split_Distribution;

------------------------------------------------------------------------------

FUNCTION Check_Account_Null RETURN VARCHAR2 IS

   l_Account_Null VARCHAR2(1) := 'Y';

BEGIN

   IF G_Segment1_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment2_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment3_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment4_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment5_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment6_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment7_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment8_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment9_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment10_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment11_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment12_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment13_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment14_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment15_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment16_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment17_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment18_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment19_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment20_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment21_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment22_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment23_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment24_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment25_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment26_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment27_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment28_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment29_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment30_Low IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment1_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment2_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment3_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment4_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment5_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment6_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment7_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment8_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment9_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment10_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment11_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment12_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment13_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment14_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment15_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment16_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment17_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment18_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment19_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment20_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment21_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment22_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment23_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment24_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment25_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment26_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment27_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment28_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment29_High IS NOT NULL THEN
      l_Account_Null := 'N';
   ELSIF G_Segment30_High IS NOT NULL THEN
      l_Account_Null := 'N';
   END IF;

   RETURN l_Account_Null;

END Check_Account_Null;

------------------------------------------------------------------------------

PROCEDURE Write_Message(p_Asset_Number  IN  VARCHAR2,
                        p_message       IN  VARCHAR2,
                        p_token1        IN  VARCHAR2,
                        p_token2        IN  VARCHAR2) IS
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);

BEGIN

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   fnd_message.set_name('OFA', p_message);

   if (p_message = 'FA_SHARED_INSERT_DEBUG') then
      fnd_message.set_token('TABLE', 'retirement batch');
   elsif p_token1 is not null then
      fnd_message.set_token('UNITS', p_token1);
      fnd_message.set_token('TOTALUNITS', p_token2);
   end if;

   l_mesg := substrb(fnd_message.get, 1, 100);

   l_string := rpad(p_asset_number, 15) || ' ' || l_mesg;

   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

   -- now process the message for the log file
   if p_message <> 'FA_SHARED_INSERT_DEBUG' then
     if p_message = 'FA_MASSRET_NOT_ENOUGH_UNITS' then
        fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => p_message,
           token1     => 'UNITS',
           value1     => p_token1,
           token2     => 'TOTALUNITS',
           value2     => p_token2 , p_log_level_rec => g_log_level_rec);
     else
        fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => p_message, p_log_level_rec => g_log_level_rec);
     end if;

   end if;

END Write_Message;

------------------------------------------------------------------------------

FUNCTION Check_Addition_Retirement(p_Asset_id           IN        NUMBER,
                                   x_Reason_Code       OUT NOCOPY VARCHAR2
                                  ) RETURN BOOLEAN IS
-- This function will check to see if the asset about to be retired has
-- already been fully retired. It also checks to see if the asset has been
-- added in the current period and whether there is a pending retirement
-- or reinstatement.
-- Returns TRUE if one of the condition is met . This is then used to
-- flag an exception in the calling module Do_Retirement.
-- Added this function for bug 586525.

       CURSOR check_pending_retirement is
              select 'FA_SHARED_PENDING_RETIREMENT'
              from   fa_retirements frt
              where  frt.asset_id = p_Asset_Id
                     AND frt.book_type_code = G_Book_Type_Code
                     AND frt.status IN  ('PENDING','REINSTATE');

       CURSOR check_processed_retirement is
              select 'FA_REC_RETIRED'
              from   fa_retirements frt,
                     fa_books bk
              where  frt.asset_id = p_Asset_Id
                     AND bk.asset_id = frt.asset_id
                     AND bk.period_counter_fully_retired is NOT NULL
                     AND bk.transaction_header_id_in =
                                         frt.transaction_header_id_in
                     AND bk.date_ineffective is null
                     AND frt.transaction_header_id_out is NULL
                     AND frt.status = 'PROCESSED'
                     AND frt.book_type_code = G_Book_Type_Code
                     AND bk.book_type_code = frt.book_type_code;

       CURSOR check_current_period_add is
               select 'FA_RET_CANT_RET_NONDEPRN'
               from   fa_transaction_headers th,
                      fa_book_controls bc,
                      fa_deprn_periods dp
               where  th.asset_id = p_Asset_id
                          AND th.book_type_code = G_Book_Type_Code
                          AND bc.book_type_code = th.book_type_code
                          AND th.transaction_type_code||''
                          = decode(bc.book_class,'CORPORATE','TRANSFER IN',
                                                               'ADDITION')
                          AND th.date_effective
                              BETWEEN dp.period_open_date
                                  AND nvl(dp.period_close_date,sysdate)
                          AND dp.book_type_code = th.book_type_code
                          AND dp.period_close_date is NULL;
       CURSOR check_other_trans_follow is
               select 'FA_SHARED_OTHER_TRX'
               from   fa_transaction_headers fth
               where  fth.asset_id = p_Asset_id
               and    fth.book_type_code = G_Book_Type_Code
               and    (fth.transaction_date_entered > G_Retirement_Date
               and     fth.transaction_type_code in ('TAX', 'REVALUATION'));

        Status          BOOLEAN := FALSE;

BEGIN  -- Check_Addition_Retirement

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('check_add_ret', 'inside', 'validation', p_log_level_rec => g_log_level_rec);
   end if;

       OPEN check_processed_retirement;
       FETCH check_processed_retirement into x_Reason_Code;
       IF (check_processed_retirement%FOUND) then
          Status := TRUE;
       ELSE
          OPEN check_pending_retirement;
          FETCH check_pending_retirement into x_Reason_Code;
          IF (check_pending_retirement%FOUND) then
              Status := TRUE;
          ELSE
             OPEN check_current_period_add;
             FETCH check_current_period_add into x_Reason_Code;
             IF (check_current_period_add%FOUND and
                 G_release = 11) then
                Status := TRUE;
             ELSE
                OPEN check_other_trans_follow;
                FETCH check_other_trans_follow into x_Reason_Code;
                IF (check_other_trans_follow%FOUND) then
                   Status := TRUE;
                END IF;
                CLOSE check_other_trans_follow;
             END IF;
             CLOSE check_current_period_add;
          END IF;
          CLOSE check_pending_retirement;
        END IF;
        CLOSE check_processed_retirement;

   if (g_log_level_rec.statement_level) then
      if (status) then
         fa_debug_pkg.add('check_add_ret', 'status', 'TRUE', p_log_level_rec => g_log_level_rec);
      else
         fa_debug_pkg.add('check_add_ret', 'status', 'FALSE', p_log_level_rec => g_log_level_rec);
      end if;
      fa_debug_pkg.add('check_add_ret', 'mesg', x_reason_code, p_log_level_rec => g_log_level_rec);
   end if;

       RETURN Status;

END;  -- Check_Addition_Retirement

----------------------------------------------------------------------------

PROCEDURE Message_tbl(p_Asset_Number  IN  VARCHAR2,
                      p_num_msg       IN OUT NOCOPY NUMBER,
                      p_msg_tbl       IN OUT NOCOPY FA_MASS_RET_PKG.out_tbl) IS

  l_unit_msg_rec  FA_MASS_RET_PKG.out_rec;
  msg_tbl   FA_MASS_RET_PKG.out_tbl;
  l_check       varchar2(30);

BEGIN

        msg_tbl := p_msg_tbl;

           l_check := 'Not inserted';
           FOR i in 1 .. msg_tbl.COUNT LOOP
                if msg_tbl(i).asset_number = p_asset_number then
                   l_check := 'Already inserted';
                end if;
           END LOOP;
           if l_check <> 'Already inserted' then
                p_num_msg := p_num_msg + 1;
                l_unit_msg_rec.asset_number := p_asset_number;
                msg_tbl(p_num_msg) := l_unit_msg_rec;
           end if;

       p_msg_tbl := msg_tbl;

END;
---------------------------------------------------------------------------
-- This function will check to see if an asset is in it's extended life and
-- if the retirement/reinstatement is in a prior period. If this is the case
-- it will return TRUE and this will be used to flag an exception in the
-- calling module Do_Retirement.
--
-- need to check if this is done within the retirement api and thus not needed
--

FUNCTION Check_Extended_Life(X_Asset_id        IN  NUMBER)
         RETURN BOOLEAN IS

   CURSOR check_asset_life_complete IS
   select 'EXTENDED LIFE'
     from fa_books bk,
          fa_deprn_periods dp
    where bk.asset_id                      = X_Asset_Id
      AND bk.book_type_code                = G_Book_Type_Code
      AND nvl(period_Counter_fully_reserved,99) <> bk.period_counter_life_complete
      AND dp.book_type_code                = bk.book_type_code
      AND bk.period_counter_life_complete is not NULL
      AND bk.date_ineffective             is null
      AND dp.period_close_date            is null
      AND G_Retirement_Date               < dp.calendar_period_open_date;

   l_extended_life    varchar2(15);

BEGIN

   OPEN check_asset_life_complete;
   FETCH check_asset_life_complete
    into l_extended_life;
   IF (check_asset_life_complete%FOUND) THEN
      CLOSE check_asset_life_complete;
      RETURN TRUE;
   END IF;

   CLOSE check_asset_life_complete;

   RETURN FALSE;

END Check_Extended_Life;

------------------------------------------------------------------------------

FUNCTION Allocate_units (p_suxess_no OUT NOCOPY NUMBER,
                         p_fail_no   OUT NOCOPY NUMBER) RETURN BOOLEAN IS


  l_remaining_units     number;
  l_asset_id            number := 0;
  temp_from_dpis        date;
  temp_to_dpis          date;
  dml_error             exception;

  l_book_type_code      fa_book_controls.book_type_code%TYPE;
  l_post_units          number;
  l_asset_post_units    number;
  l_dist_post_units     number;
  l_diff        number;
  l_dist_diff   number;
  i             number;
  num_msg       number;

/*
  TYPE out_rec IS RECORD ( ASSET_NUMBER         VARCHAR2(15));

  l_unit_msg_rec  out_rec;

  TYPE out_tbl IS TABLE OF out_rec index by binary_integer;

  msg_tbl   out_tbl;
*/

  l_unit_msg_rec  FA_MASS_RET_PKG.out_rec;
  msg_tbl   FA_MASS_RET_PKG.out_tbl;

-- declare 2nd round of allocation

  l_asset_dist_tbl      FA_API_TYPES.asset_dist_tbl_type;
  l_2nd_asset_id        number;
  l_2nd_asset_number    fa_additions_b.asset_number%TYPE;
  l_2nd_cost_retired    number;
  l_2nd_current_units   number;
  l_2nd_dpis            date;
  l_reason_code         varchar2(30);
  error_found           exception;
  l_dist_cost           number;
  l_dist_count          number;
  l_mass_external_retire_id     number;
  l_Null_Segment_Flag VARCHAR2(1);

-- allocate units
cursor c_asset_assignments is
  Select  ad.asset_id,
          ad.asset_number,
          ad.current_units,
          bk.cost,
          mer.units mer_units,
          mer.mass_external_retire_id,
          mer.code_combination_id,
          mer.location_id,
          mer.assigned_to
  From  fa_mass_ext_retirements mer,
        fa_books bk,
        fa_additions ad
  Where  mer.batch_name = G_batch_name   -- current batch
  And    mer.asset_id = bk.asset_id
  And    mer.book_type_code = bk.book_type_code
  And    bk.date_ineffective is null
  And    bk.date_placed_in_service
                between nvl(temp_from_dpis, bk.date_placed_in_service -1)
                and nvl(temp_to_dpis, bk.date_placed_in_service +1)
  and    ad.asset_id = mer.asset_id
  order by bk.date_placed_in_service, bk.asset_id;
  aurec   c_asset_assignments%ROWTYPE;
-- rn ideally order by code_combination_id first. Null should be
-- taken first.


-- rn instead of having units desc in order by,
-- loop through and allocate the mer rows having units assigned first.
-- will be a safer approach.
-- if so, it should be done first for both inside date range allocation
-- and for the outside allocation.
-- if inside and/or allocation has allocated all units, before all records
-- have been treated, other records having units already assigned should
-- be cleared (and later deleted).

-- A solution would be to insert review_status = 'DELETE',
-- for current batch when g_units has a value for the initial
-- original code loop.
-- Then when in allocate units section update/insert these rows
-- to POST. Remaining rows for the batch with DELETE status will
-- be deleted.

-- allocate units outside dpis  range

  CURSOR qual_ass_by_asset_number_out IS
    SELECT
           faa.asset_id,
           faa.asset_number,
           fab.date_placed_in_service,
           fab.cost,
           faa.current_units
      FROM fa_book_controls fbc,
           fa_books         fab,
           fa_additions_b   faa
     WHERE faa.asset_id = fab.asset_id
       AND (faa.asset_key_ccid = G_Asset_Key_Id
             OR G_Asset_Key_Id IS NULL)
       AND faa.asset_category_id = nvl(G_Category_Id,faa.asset_category_id)
       AND fab.cost >= nvl(G_From_Cost,fab.cost)
       AND fab.cost <= nvl(G_To_Cost,fab.cost)
       AND ((G_group_asset_id = -1 and -- group change
             fab.group_asset_id is null) OR -- group change
            (G_group_asset_id = -99) OR -- group change
            (G_group_asset_id > 0 and -- group change
             nvl(fab.group_asset_id, -999) = g_group_asset_id)) -- group change
       AND nvl(fab.period_counter_fully_reserved,-99999) =
          decode(G_Fully_Rsvd_Flag,
               'YES',fab.period_counter_fully_reserved,
               'NO',-99999,
               nvl(fab.period_counter_fully_reserved,-99999))
       AND faa.asset_number                >=
           nvl(G_From_Asset_Number, faa.asset_number)
       AND faa.asset_number                <=
           nvl(G_To_Asset_Number,  faa.asset_number)
       AND fab.date_placed_in_service
             NOT BETWEEN nvl(Temp_From_DPIS,fab.date_placed_in_service-1)
                  AND nvl(Temp_To_DPIS  ,fab.date_placed_in_service+1)
       AND (faa.model_number = G_model_number
                OR G_model_number IS NULL)
       AND (faa.serial_number  = G_serial_number
                OR G_serial_number IS NULL)
       AND (faa.tag_number      = G_tag_number
                OR G_tag_number IS NULL)
       AND (faa.manufacturer_name = G_manufacturer_name
                OR G_manufacturer_name IS NULL)
       AND fab.book_type_code = fbc.book_type_code
       AND fbc.date_ineffective is null
       AND EXISTS (SELECT null
                     FROM fa_distribution_history fad,
                          gl_code_combinations    gcc
                    WHERE fad.asset_id = faa.asset_id
                      AND fad.code_combination_id = gcc.code_combination_id
                      AND (fad.assigned_to = G_Employee_Id
                           OR G_Employee_Id IS NULL)
                      AND (fad.location_id = G_Location_Id
                           OR G_Location_Id IS NULL)
                      AND fad.date_ineffective IS NULL
                      AND (gcc.segment1 BETWEEN G_Segment1_Low
                                            AND G_Segment1_High
                           OR G_Segment1_Low IS NULL)
                      AND (gcc.segment2 BETWEEN G_Segment2_Low
                                            AND G_Segment2_High
                           OR G_Segment2_Low IS NULL)
                      AND (gcc.segment3 BETWEEN G_Segment3_Low
                                            AND G_Segment3_High
                           OR G_Segment3_Low IS NULL)
                      AND (gcc.segment4 BETWEEN G_Segment4_Low
                                            AND G_Segment4_High
                           OR G_Segment4_Low IS NULL)
                      AND (gcc.segment5 BETWEEN G_Segment5_Low
                                            AND G_Segment5_High
                           OR G_Segment5_Low IS NULL)
                      AND (gcc.segment6 BETWEEN G_Segment6_Low
                                            AND G_Segment6_High
                           OR G_Segment6_Low IS NULL)
                      AND (gcc.segment7 BETWEEN G_Segment7_Low
                                            AND G_Segment7_High
                           OR G_Segment7_Low IS NULL)
                      AND (gcc.segment8 BETWEEN G_Segment8_Low
                                            AND G_Segment8_High
                           OR G_Segment8_Low IS NULL)
                      AND (gcc.segment9 BETWEEN G_Segment9_Low
                                            AND G_Segment9_High
                           OR G_Segment9_Low IS NULL)
                      AND (gcc.segment10 BETWEEN G_Segment10_Low
                                             AND G_Segment10_High
                           OR G_Segment10_Low IS NULL)
                      AND (gcc.segment11 BETWEEN G_Segment11_Low
                                             AND G_Segment11_High
                           OR G_Segment11_Low IS NULL)
                      AND (gcc.segment12 BETWEEN G_Segment12_Low
                                             AND G_Segment12_High
                           OR G_Segment12_Low IS NULL)
                      AND (gcc.segment13 BETWEEN G_Segment13_Low
                                             AND G_Segment13_High
                           OR G_Segment13_Low IS NULL)
                      AND (gcc.segment14 BETWEEN G_Segment14_Low
                                             AND G_Segment14_High
                           OR G_Segment14_Low IS NULL)
                      AND (gcc.segment15 BETWEEN G_Segment15_Low
                                             AND G_Segment15_High
                           OR G_Segment15_Low IS NULL)
                      AND (gcc.segment16 BETWEEN G_Segment16_Low
                                             AND G_Segment16_High
                           OR G_Segment16_Low IS NULL)
                      AND (gcc.segment17 BETWEEN G_Segment17_Low
                                             AND G_Segment17_High
                           OR G_Segment17_Low IS NULL)
                      AND (gcc.segment18 BETWEEN G_Segment18_Low
                                             AND G_Segment18_High
                           OR G_Segment18_Low IS NULL)
                      AND (gcc.segment19 BETWEEN G_Segment19_Low
                                             AND G_Segment19_High
                           OR G_segment19_Low IS NULL)
                      AND (gcc.segment20 BETWEEN G_Segment20_Low
                                             AND G_Segment20_High
                           OR G_segment20_Low IS NULL)
                      AND (gcc.segment21 BETWEEN G_Segment21_Low
                                             AND G_Segment21_High
                           OR G_segment21_Low IS NULL)
                      AND (gcc.segment22 BETWEEN G_Segment22_Low
                                             AND G_Segment22_High
                           OR G_segment22_Low IS NULL)
                      AND (gcc.segment23 BETWEEN G_Segment23_Low
                                             AND G_Segment23_High
                           OR G_segment23_Low IS NULL)
                      AND (gcc.segment24 BETWEEN G_Segment24_Low
                                             AND G_Segment24_High
                           OR G_segment24_Low IS NULL)
                      AND (gcc.segment25 BETWEEN G_Segment25_Low
                                             AND G_Segment25_High
                           OR G_segment25_Low IS NULL)
                      AND (gcc.segment26 BETWEEN G_Segment26_Low
                                             AND G_Segment26_High
                           OR G_segment26_Low IS NULL)
                      AND (gcc.segment27 BETWEEN G_Segment27_Low
                                             AND G_Segment27_High
                           OR G_segment27_Low IS NULL)
                      AND (gcc.segment28 BETWEEN G_Segment28_Low
                                             AND G_Segment28_High
                           OR G_segment28_Low IS NULL)
                      And (gcc.segment29 BETWEEN G_Segment29_Low
                                             AND G_Segment29_High
                           OR G_segment29_Low IS NULL)
                      AND (gcc.segment30 BETWEEN G_Segment30_Low
                                             AND G_Segment30_High
                           OR G_segment30_Low IS NULL))
       AND (faa.asset_type = G_Asset_Type OR G_Asset_Type IS NULL)
       AND faa.asset_type IN ('CIP','CAPITALIZED','EXPENSED')
       AND fbc.book_type_code = G_Book_Type_Code
       AND fab.date_ineffective IS NULL
     ORDER BY fab.date_placed_in_service;


cursor c_mer is
  select units
  from fa_mass_ext_retirements
  where book_type_code = G_book_type_code
  and     asset_id  = l_asset_id
  and     review_status = 'POST'
  and     units is not null
  and     batch_name <> G_batch_name;


cursor c_dh is
  select *
  from fa_distribution_history dh
  where dh.asset_id = l_asset_id
  and dh.location_id = nvl(aurec.location_id, dh.location_id)
  and dh.code_combination_id = nvl(aurec.code_combination_id, dh.code_combination_id)
  and nvl(dh.assigned_to, -9999) = nvl(aurec.assigned_to, -9999)
  and dh.date_ineffective is null
  order by distribution_id;


-- there is no way to know which
-- distribution that is best fit. yes, if location_id,
-- code_combination_id or assigned_to is provided. Then choose these first.
  dhrec c_dh%ROWTYPE;


  l_check               varchar2(30);
  l_prev_asset_id       number;
  l_slask               number;
  error                 varchar2(100);
  l_calling_fn   varchar2(40) := 'FA_MASS_RET_PKG.allocate_units';

Begin


  if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'In unit allocation:units',g_units , p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'In unit allocation:extend',g_extend_search , p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'In unit allocation:from_dpis',g_from_dpis, p_log_level_rec => g_log_level_rec);
  end if;

  If    (g_extend_search = 'YES'
        and (g_from_dpis is not null and g_to_dpis is not null)
        and  g_units is not null) then

     temp_from_dpis     := g_from_dpis;
     temp_to_dpis       := g_to_dpis;
     g_from_dpis        := '';
     g_to_dpis          := '';

  end if;

  msg_tbl.delete;
  num_msg := 0;
  p_suxess_no := 0;
  l_prev_asset_id := '';



-- FIRST ROUND OF ALLOCATION
   l_remaining_units := g_units;
   open c_asset_assignments;
   fetch c_asset_assignments into aurec;
   While (c_asset_assignments%FOUND and l_remaining_units > 0) loop


      if (g_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'In aurec-loop: remaining units',l_remaining_units , p_log_level_rec => g_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'In aurec-loop: asset_id',aurec.asset_Id , p_log_level_rec => g_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'In aurec-loop: mer_units',aurec.mer_units, p_log_level_rec => g_log_level_rec);
      end if;

      -- this solution assumes that units are entered in fa_mass_ext_retirements records.(verified ok).

      if l_asset_id <> aurec.asset_id then

         l_asset_id := aurec.asset_id;
         open c_mer;
         fetch c_mer into l_post_units;
         if c_mer%NOTFOUND then
             l_post_units := 0;
         end if;
         close c_mer;
      end if;

      if nvl(aurec.mer_units,0) <= l_remaining_units then
        if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'aurec.mer_units <= rem.units',
                                aurec.mer_units , p_log_level_rec => g_log_level_rec);
        end if;

        if l_post_units = 0 then
           if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'aurec, post_units = 0',
                                l_post_units , p_log_level_rec => g_log_level_rec);
           end if;

           l_remaining_units := l_remaining_units -  aurec.mer_units;

           Update fa_mass_ext_retirements
           Set review_status = 'POST',
               calc_gain_loss_flag = 'YES'
           Where mass_external_retire_id = aurec.mass_external_retire_id;


           message_tbl(aurec.asset_number, num_msg, msg_tbl);

           if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'mer_units >0, units',l_remaining_units , p_log_level_rec => g_log_level_rec);
           end if;


        else -- l_post_units >  0


           select nvl(sum(units),0)
           into l_asset_post_units
           from fa_mass_ext_retirements
           where book_type_code = g_book_type_code
           and   asset_id = l_asset_id
           and   review_status = 'POST'
           and   batch_name <> g_batch_name;

           if (g_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'aurec, post_units > 0',
                        l_asset_post_units , p_log_level_rec => g_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'aurec.ccid is null, current_units',
                        aurec.current_units, p_log_level_rec => g_log_level_rec);
           end if;


           if aurec.code_combination_id is null then
              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'aurec.ccid is null',
                                '', p_log_level_rec => g_log_level_rec);
              end if;

              if aurec.current_units > l_asset_post_units then


                 l_diff := aurec.current_units - l_asset_post_units;
                 open c_dh;
                 fetch c_dh into dhrec;
                 While (c_dh%FOUND and l_diff > 0) loop

-- 1. check if any asset exists with distribution info

                    select nvl(sum(units),0)
                    into l_dist_post_units
                    from fa_mass_ext_retirements
                    where book_type_code = g_book_type_code
                    and   asset_id = l_asset_id
                    and   review_status = 'POST'
                    and   batch_name <> g_batch_name
                    and   code_combination_id= dhrec.code_combination_id
                    and   location_id = dhrec.location_id
                    and   nvl(assigned_to,-99) = nvl(dhrec.assigned_to,-99);

                    if dhrec.units_assigned > l_dist_post_units then
                       l_dist_diff := dhrec.units_assigned - l_dist_post_units;
                       if l_dist_diff <= l_diff then

                           if not insert_details(
                                aurec.asset_id,
                                l_dist_diff,
                                dhrec.code_combination_id,
                                dhrec.location_id,
                                dhrec.assigned_to,
                                aurec.cost,
                                aurec.current_units) then

                                raise dml_error;

                           end if;
                           if (g_log_level_rec.statement_level) then
                             fa_debug_pkg.add(l_calling_fn,'insert details A',
                                l_dist_diff, p_log_level_rec => g_log_level_rec);
                           end if;

                           message_tbl(aurec.asset_number, num_msg, msg_tbl);

                           l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_dist_post_units);
                           l_diff := l_diff - (dhrec.units_assigned - l_dist_post_units);

                        end if; -- l_dist_diff

                     end if; -- dhrec.units_assigned > ...
                     fetch c_dh into dhrec;
                  END LOOP;
                  close c_dh;

                 if (g_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn, 'check all dists,continue with no dist info rows', l_diff, p_log_level_rec => g_log_level_rec);
                 end if;


-- We've checked all distributions, now there are only occurences with
-- no distribution info left.
                  if l_diff > 0 then
                     open c_dh;
                     fetch c_dh into dhrec;
                     While (c_dh%FOUND and l_diff > 0) loop

                        if (g_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'while loop,diff > 0',
                                l_diff, p_log_level_rec => g_log_level_rec);
                        end if;

                        if dhrec.units_assigned > l_asset_post_units then
                           l_dist_diff := dhrec.units_assigned - l_asset_post_units;

                           if (g_log_level_rec.statement_level) then
                              fa_debug_pkg.add(l_calling_fn, 'while loop,dist_diff ',
                                l_dist_diff, p_log_level_rec => g_log_level_rec);
                           end if;

                           if l_dist_diff <= l_diff then

                             if not insert_details(
                                        aurec.asset_id,
                                        l_dist_diff,
                                        dhrec.code_combination_id,
                                        dhrec.location_id,
                                        dhrec.assigned_to,
                                        aurec.cost,
                                        aurec.current_units) then
                                raise dml_error;
                             end if;
                             if (g_log_level_rec.statement_level) then
                               fa_debug_pkg.add(l_calling_fn,'insert details B',
                                      l_dist_diff, p_log_level_rec => g_log_level_rec);
                             end if;

                             message_tbl(aurec.asset_number, num_msg, msg_tbl);


                             l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_asset_post_units);
                             l_diff := l_diff - (dhrec.units_assigned - l_asset_post_units);

                           end if; -- l_dist_diff
                         end if; -- dhrec.units_assigned > ...
                         fetch c_dh into dhrec;
                      END LOOP;
                      close c_dh;
                   end if; -- l_diff >

-- when aurec.current_units is not greater do nothing.
              end if; -- aurec.current_units >


-- a partial unit retirement

           else -- code_combination_id is not null
-- bug 3161864
              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'aurec.ccid is not null',
                                aurec.code_combination_id, p_log_level_rec => g_log_level_rec);

                 fa_debug_pkg.add(l_calling_fn, 'aurec.mer_units',
                                aurec.mer_units, p_log_level_rec => g_log_level_rec);

                 fa_debug_pkg.add(l_calling_fn, 'aurec.current_units',
                                aurec.current_units, p_log_level_rec => g_log_level_rec);

                 fa_debug_pkg.add(l_calling_fn, 'l_asset_post_units',
                                l_asset_post_units, p_log_level_rec => g_log_level_rec);

              end if;

              if aurec.current_units > l_asset_post_units then

                 select nvl(sum(units),0)
                 into l_dist_post_units
                 from fa_mass_ext_retirements
                 where book_type_code = g_book_type_code
                 and   asset_id = l_asset_id
                 and   review_status = 'POST'
                 and   batch_name <> g_batch_name
                 and   code_combination_id =
                        aurec.code_combination_id
                 and   location_id =
                        aurec.location_id
                 and   nvl(assigned_to,-99) =
                        nvl(aurec.assigned_to,-99);

              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'l_dist_post_units',
                                l_dist_post_units, p_log_level_rec => g_log_level_rec);

              end if;


                 if aurec.mer_units > l_dist_post_units then


                    if l_remaining_units <= (aurec.mer_units - l_dist_post_units) then
                       if not insert_details(
                          aurec.asset_id,
                          l_remaining_units,
                          aurec.code_combination_id,
                          aurec.location_id,
                          aurec.assigned_to,
                          aurec.cost,
                          aurec.current_units) then
                                raise dml_error;
                        end if;

                        message_tbl(aurec.asset_number, num_msg, msg_tbl);

                        l_remaining_units := 0;

                    else -- l_remaining_units > ...

                        if not insert_details(
                          aurec.asset_id,
                          aurec.mer_units - l_dist_post_units,
                          aurec.code_combination_id,
                          aurec.location_id,
                          aurec.assigned_to,
                          aurec.cost,
                          aurec.current_units) then
                                raise dml_error;
                        end if;

                        if (g_log_level_rec.statement_level) then
                         l_slask :=     aurec.mer_units - l_dist_post_units;
                         fa_debug_pkg.add(l_calling_fn,'insert details C',
                                l_slask, p_log_level_rec => g_log_level_rec);
                        end if;

                        message_tbl(aurec.asset_number, num_msg, msg_tbl);

                        l_remaining_units := l_remaining_units -
                              (aurec.mer_units - l_dist_post_units);

                    end if;  -- l_remaining_units...
                  end if; -- if aurec.mer_units >...

               end if; -- aurec.current_unit > ...skip asset if not meet crit.
            end if; -- expense_ccid is null
        end if; -- l_post_units = 0

      else -- aurec.mer_units > l_remaining_units...

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'units_assigned > l_remain_units',
                                l_remaining_units, p_log_level_rec => g_log_level_rec);
         end if;

         if l_post_units = 0 then

            if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'post_units = 0',
                                l_post_units, p_log_level_rec => g_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'location_id',
                                aurec.location_id, p_log_level_rec => g_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'code_combination_id',
                                aurec.code_combination_id, p_log_level_rec => g_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'assigned_to',
                                aurec.assigned_to, p_log_level_rec => g_log_level_rec);
            end if;
-- bug 3163661 - in this branch.
-- obtain distributions to partially retire from
            open c_dh;
            fetch c_dh into dhrec;
            While (c_dh%FOUND and l_remaining_units > 0) loop

               if dhrec.units_assigned >= l_remaining_units then

                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,
                        'Before Insert details B, units_assigned',
                        dhrec.units_assigned, p_log_level_rec => g_log_level_rec);
                  end if;

               -- insert partial unit retirement
                  if not insert_details(
                        aurec.asset_id,
                        l_remaining_units,
                        dhrec.code_combination_id,
                        dhrec.location_id,
                        dhrec.assigned_to,
                        aurec.cost,
                        aurec.current_units) then

                       raise dml_error;

                   end if;
                   if (g_log_level_rec.statement_level) then
                            fa_debug_pkg.add(l_calling_fn,'insert details D',
                                l_remaining_units, p_log_level_rec => g_log_level_rec);
                   end if;

                   message_tbl(aurec.asset_number, num_msg, msg_tbl);

                   if (g_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn, '
                                        aurec.., remaining units',
                                        0 , p_log_level_rec => g_log_level_rec);
                   end if;

                   l_remaining_units := 0;
                else  -- units_assigned

-- insert partial unit retirement
                   if (g_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn,
                         'Before Insert details C, units_assigned',
                          dhrec.units_assigned, p_log_level_rec => g_log_level_rec);
                   end if;

                   if not insert_details(
                        aurec.asset_id,
                        dhrec.units_assigned,
                        dhrec.code_combination_id,
                        dhrec.location_id,
                        dhrec.assigned_to,
                        aurec.cost,
                        aurec.current_units) then

                         raise dml_error;

                   end if;

                   if (g_log_level_rec.statement_level) then
                         fa_debug_pkg.add(l_calling_fn,'insert details E',
                                dhrec.units_assigned, p_log_level_rec => g_log_level_rec);

                   end if;

                   message_tbl(aurec.asset_number, num_msg, msg_tbl);

                   l_remaining_units := l_remaining_units - dhrec.units_assigned;
                   if (g_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn,
                        'aurec2.., remaining units',
                        l_remaining_units , p_log_level_rec => g_log_level_rec);
                   end if;

                end if;
                fetch c_dh into dhrec;
             end loop; -- dhloop
             close c_dh;

          else  -- l_post_units >  0
-- dfbug here...

-- units have been already been put in fa_mer for this asset_id.
              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'post_units >0 ',
                                l_post_units, p_log_level_rec => g_log_level_rec);
              end if;

             select nvl(sum(units),0)
             into l_asset_post_units
             from fa_mass_ext_retirements
             where book_type_code = g_book_type_code
             and   asset_id = l_asset_id
             and   review_status = 'POST'
             and   batch_name <> g_batch_name;


-- when code_combination_id is null we must provide the distribution info
-- for the insert.
             if aurec.code_combination_id is null then


                if (g_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'aurec.ccid is null',
                                aurec.code_combination_id, p_log_level_rec => g_log_level_rec);
                end if;
                if aurec.mer_units > l_asset_post_units then
                   if (g_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn,
                                        'mer_units > l_asset_post_units',
                                        l_asset_post_units, p_log_level_rec => g_log_level_rec);
                   end if;

                   l_diff := aurec.mer_units - l_asset_post_units;
                   open c_dh;
                   fetch c_dh into dhrec;
                   While (c_dh%FOUND and l_remaining_units > 0) loop


                      select nvl(sum(units),0)
                      into l_dist_post_units
                      from fa_mass_ext_retirements
                      where book_type_code = g_book_type_code
                      and   asset_id = l_asset_id
                      and   review_status = 'POST'
                      and   batch_name <> g_batch_name
                      and   code_combination_id= dhrec.code_combination_id
                      and   location_id = dhrec.location_id
                      and   nvl(assigned_to,-99) = nvl(dhrec.assigned_to,-99);

                      if (g_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn,
                                        'In while loop, post_units',
                                        l_dist_post_units, p_log_level_rec => g_log_level_rec);
                      end if;
                      if dhrec.units_assigned > l_dist_post_units  then


                         l_dist_diff := dhrec.units_assigned - l_dist_post_units;

                         if (g_log_level_rec.statement_level) then
                                fa_debug_pkg.add(l_calling_fn,
                                                'units_assign > post_units',
                                                l_dist_diff     , p_log_level_rec => g_log_level_rec);
                         end if;

                         if l_dist_diff <= l_remaining_units then

                              if not insert_details(
                                aurec.asset_id,
                                l_dist_diff,
                                dhrec.code_combination_id,
                                dhrec.location_id,
                                dhrec.assigned_to,
                                aurec.cost,
                                aurec.current_units) then

                                        raise dml_error;
                              end if;
                              if (g_log_level_rec.statement_level) then
                                 fa_debug_pkg.add(l_calling_fn,'insert details F',
                                    l_dist_diff, p_log_level_rec => g_log_level_rec);
                              end if;

                              message_tbl(aurec.asset_number, num_msg, msg_tbl);

                              l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_dist_post_units);
                              l_diff := l_diff - (dhrec.units_assigned - l_dist_post_units);

                         else -- l_dist_diff
-- rn implement same construct elsewhere....
                              if not insert_details(
                                aurec.asset_id,
                                l_remaining_units,
                                dhrec.code_combination_id,
                                dhrec.location_id,
                                dhrec.assigned_to,
                                aurec.cost,
                                aurec.current_units) then

                                        raise dml_error;
                              end if;
                              if (g_log_level_rec.statement_level) then
                                 fa_debug_pkg.add(l_calling_fn,'insert details FF',
                                    l_remaining_units, p_log_level_rec => g_log_level_rec);
                              end if;

                              message_tbl(aurec.asset_number, num_msg, msg_tbl);

                              l_remaining_units := 0;
                              l_diff := 0;

                         end if; -- l_dist_diff

                   end if; -- dhrec.units_assigned > ...
                   fetch c_dh into dhrec;
                END LOOP;
                close c_dh;

                if (g_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'Check occurences with no dist info', l_remaining_units, p_log_level_rec => g_log_level_rec);
                end if;
--
-- We've checked all distributions, now there are only occurences with
-- no distribution info left.

-- changed for bug 3880664
--              if l_remaining_units > 0 then
                if l_diff > 0 then
                   open c_dh;
                   fetch c_dh into dhrec;

-- changed for bug 3880664
--                 While (c_dh%FOUND and l_remaining_units > 0) loop

                   While (c_dh%FOUND and l_diff > 0) loop

                      if (g_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'In while loop, post_units',
                        l_asset_post_units      , p_log_level_rec => g_log_level_rec);
                      end if;
                      if dhrec.units_assigned > l_asset_post_units then
                         l_dist_diff := dhrec.units_assigned - l_asset_post_units;
                         if (g_log_level_rec.statement_level) then
                            fa_debug_pkg.add(l_calling_fn, 'units_assign > post_units',
                             l_dist_diff        , p_log_level_rec => g_log_level_rec);
                         end if;

                         if l_dist_diff <= l_remaining_units then

                            if not insert_details(
                                        aurec.asset_id,
                                        l_dist_diff,
                                        dhrec.code_combination_id,
                                        dhrec.location_id,
                                        dhrec.assigned_to,
                                        aurec.cost,
                                        aurec.current_units) then

                                         raise dml_error;
                            end if;
                            if (g_log_level_rec.statement_level) then
                            fa_debug_pkg.add(l_calling_fn,'insert details G',
                                l_dist_diff, p_log_level_rec => g_log_level_rec);
                            end if;

                            message_tbl(aurec.asset_number, num_msg, msg_tbl);

                            l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_asset_post_units);
                            l_diff := l_diff - (dhrec.units_assigned - l_asset_post_units);

                         else -- l_dist_diff

                              if not insert_details(
                                aurec.asset_id,
                                l_remaining_units,
                                dhrec.code_combination_id,
                                dhrec.location_id,
                                dhrec.assigned_to,
                                aurec.cost,
                                aurec.current_units) then

                                        raise dml_error;
                              end if;
                              if (g_log_level_rec.statement_level) then
                                 fa_debug_pkg.add(l_calling_fn,'insert details GG',
                                    l_remaining_units, p_log_level_rec => g_log_level_rec);
                              end if;

                              message_tbl(aurec.asset_number, num_msg, msg_tbl);

                              l_remaining_units := 0;
                              l_diff := 0;


                         end if; -- l_dist_diff
                      end if; -- dhrec.units_assigned > ...
                      fetch c_dh into dhrec;
                   END LOOP;
                   close c_dh;

                end if; -- l_remaining_units >
             end if; -- l_2nd_current_units >

-- a partial unit retirement

          else -- code_combination_id is not null
-- bug 3161864
             if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'aurec.ccid is not null',
                                aurec.code_combination_id, p_log_level_rec => g_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'aurec.mer_units',
                                aurec.mer_units, p_log_level_rec => g_log_level_rec);

                 fa_debug_pkg.add(l_calling_fn, 'aurec.current_units',
                                aurec.current_units, p_log_level_rec => g_log_level_rec);

                 fa_debug_pkg.add(l_calling_fn, 'l_asset_post_units',
                                l_asset_post_units, p_log_level_rec => g_log_level_rec);

              end if;
--
-- ------    if aurec.mer_units > l_asset_post_units then

             if aurec.current_units > l_asset_post_units then


                 select nvl(sum(units),0)
                 into l_dist_post_units
                 from fa_mass_ext_retirements
                 where book_type_code = g_book_type_code
                 and   asset_id = l_asset_id
                 and   review_status = 'POST'
                 and   batch_name <> g_batch_name
                 and   code_combination_id =
                        nvl(aurec.code_combination_id,code_combination_id)
                 and   location_id =
                        nvl(aurec.location_id, location_id)
                 and   nvl(assigned_to,-99) =
                        nvl(aurec.assigned_to,-99);

                 if aurec.mer_units >   l_dist_post_units then


                    if l_remaining_units <= (aurec.mer_units - l_dist_post_units) then
                       if not insert_details(
                          aurec.asset_id,
                          l_remaining_units,
                          aurec.code_combination_id,
                          aurec.location_id,
                          aurec.assigned_to,
                          aurec.cost,
                          aurec.current_units) then

                           raise dml_error;
                        end if;

                        message_tbl(aurec.asset_number, num_msg, msg_tbl);

                        l_remaining_units := 0;

                    else -- l_remaining_units > ...

                       if not insert_details(
                          aurec.asset_id,
                          aurec.mer_units - l_dist_post_units,
                          aurec.code_combination_id,
                          aurec.location_id,
                          aurec.assigned_to,
                          aurec.cost,
                          aurec.current_units) then

                             raise dml_error;
                       end if;

                       if (g_log_level_rec.statement_level) then
                          l_slask := aurec.mer_units - l_dist_post_units;
                          fa_debug_pkg.add(l_calling_fn,'insert details H',
                                l_slask, p_log_level_rec => g_log_level_rec);
                       end if;

                       message_tbl(aurec.asset_number, num_msg, msg_tbl);

                       l_remaining_units := l_remaining_units -
                                (aurec.mer_units
                                 - l_dist_post_units);
                    end if; -- l_remaining_units

                 end if; -- aurec.mer_units > dist_units

              end if; -- aurec.mer_units > ...skip asset if not meet crit.

           end if; -- code_combination_id

        end if; -- post_units

     end if; -- units_assigned

     fetch c_asset_assignments into aurec;

  End loop; -- c_assignments loop
  close c_asset_assignments;


  if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'Before 2nd round of allocation',l_remaining_units , p_log_level_rec => g_log_level_rec);
  end if;

  -- SECOND ROUND OF ALLOCATION IF EXTENDED SEARCH BEYOND DATES USING FIFO
  -- This is the condition to search for additional quantities outside dpis range.

   If  (g_extend_search = 'YES'
   and (temp_from_dpis is not null and temp_to_dpis is not null)
   and l_remaining_units > 0) then

       if (g_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn,
                            '2ND ROUND OF ALLOCATION, temp_from_dpis',
                            temp_from_dpis, p_log_level_rec => g_log_level_rec);
           fa_debug_pkg.add(l_calling_fn,
                            '2ND ROUND OF ALLOCATION,temp_to_dpis',
                            temp_to_dpis , p_log_level_rec => g_log_level_rec);
       end if;

-- COLLECT FOR 2ND ROUND
-- subcomponents are not considered for the outside date range fetch.

    l_asset_id := 0;
    OPEN qual_ass_by_asset_number_out;

    FETCH qual_ass_by_asset_number_out
         INTO l_2nd_Asset_Id,
               l_2nd_asset_number,
               l_2nd_dpis,
               l_2nd_Cost_Retired,
               l_2nd_current_units;
    WHILE (qual_ass_by_asset_number_out%FOUND and l_remaining_units > 0) LOOP


        l_asset_dist_tbl.delete;

         if (g_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn,
                            'In qual loop, remaining units',
                            l_remaining_units , p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'In qual loop, asset_id:',
                l_2nd_asset_id, p_log_level_rec => g_log_level_rec);
         end if;

        IF not (Check_Addition_Retirement(l_2nd_asset_id, l_Reason_Code)) THEN

           IF not (Check_Extended_Life(l_2nd_asset_id)) then

              l_Null_Segment_Flag := Check_Account_Null;
              IF (g_location_id is not null or
                        g_employee_id is not null or
                        l_null_segment_flag = 'N') then


                 if (g_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn, 'Before check_split call',
                        '', p_log_level_rec => g_log_level_rec);
                 end if;

                 IF not Check_Split_Distribution(l_2nd_asset_id,
                   l_asset_dist_tbl
                   )  then
                        raise error_found;
                 end if;

             end if; -- g_location...

             if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'In qual loop 2 ',
                l_2nd_asset_id, p_log_level_rec => g_log_level_rec);
             end if;

             if l_asset_dist_tbl.count = 0 then
                if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'After check_split dist.', ''  , p_log_level_rec => g_log_level_rec);
                end if;

                l_asset_dist_tbl(1).expense_ccid := '';
                l_asset_dist_tbl(1).location_ccid := '';
                l_asset_dist_tbl(1).assigned_to := '';
                l_asset_dist_tbl(1).units_assigned := l_2nd_current_units;
             end if;

             if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'Before l_asset_dist_tbl loop',
                '', p_log_level_rec => g_log_level_rec);
             end if;


             For l_dist_count in 1..l_asset_dist_tbl.count loop


-- ALLOCATE 2ND ROUND

                if (g_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'In l_asset_dist_tbl loop',
                   '', p_log_level_rec => g_log_level_rec);
                end if;

                if l_asset_id <> l_2nd_asset_id then

                   l_asset_id := l_2nd_asset_id;

                   open c_mer;
                   fetch c_mer into l_post_units;
                   if c_mer%NOTFOUND then
                       l_post_units := 0;
                   end if;
                   close c_mer;
                end if;


                if l_asset_dist_tbl(l_dist_count).units_assigned <= l_remaining_units then

                   if (g_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn, 'If units_assigned <= rem.',
                      l_remaining_units, p_log_level_rec => g_log_level_rec);
                   end if;

                   if (l_post_units = 0) then

                   if (g_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn, 'l_post_units = 0',
                      '', p_log_level_rec => g_log_level_rec);
                   end if;

                    l_remaining_units := l_remaining_units -  l_asset_dist_tbl(l_dist_count).units_assigned;

                    if (g_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn, 'Before Insert details A, units',
                        l_asset_dist_tbl(l_dist_count).units_assigned);
                     end if;

                     if not insert_details(
                        l_2nd_asset_id,
                        l_asset_dist_tbl(l_dist_count).units_assigned,
                        l_asset_dist_tbl(l_dist_count).expense_ccid,
                        l_asset_dist_tbl(l_dist_count).location_ccid,
                        l_asset_dist_tbl(l_dist_count).assigned_to,
                        l_2nd_cost_retired,
                        l_asset_dist_tbl(l_dist_count).units_assigned) then

                        raise dml_error;

                     end if;
                     if (g_log_level_rec.statement_level) then
                            fa_debug_pkg.add(l_calling_fn,'insert details I',
                                l_asset_dist_tbl(l_dist_count).units_assigned);
                     end if;

                     message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                     if (g_log_level_rec.statement_level) then
                         fa_debug_pkg.add(l_calling_fn,
                                'Outside.., remaining units',
                                l_remaining_units , p_log_level_rec => g_log_level_rec);
                     end if;

                   else -- l_post_units > 0

-- not a partial unit retirement

-- need to prorate the units over distributions.....
                      select nvl(sum(units),0)
                      into l_asset_post_units
                      from fa_mass_ext_retirements
                      where book_type_code = g_book_type_code
                      and   asset_id = l_asset_id
                      and   review_status = 'POST'
                      and   batch_name <> g_batch_name;


                        if (g_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'Before expense_ccid is null',
                           '', p_log_level_rec => g_log_level_rec);
                        end if;

                      if l_asset_dist_tbl(l_dist_count).expense_ccid is null then

                        if (g_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'expense_ccid is null',
                           '', p_log_level_rec => g_log_level_rec);
                        end if;


                         if l_2nd_current_units > l_asset_post_units then

                                if (g_log_level_rec.statement_level) then
                                   fa_debug_pkg.add(l_calling_fn, 'l_2nd_current_units > l_post_units',
                                   l_asset_post_units, p_log_level_rec => g_log_level_rec);
                                end if;

                            l_diff := l_2nd_current_units - l_asset_post_units;
                               open c_dh;
                               fetch c_dh into dhrec;
                               While (c_dh%FOUND and l_diff > 0) loop

                        if (g_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'In dh loop, l_diff',
                           l_diff, p_log_level_rec => g_log_level_rec);
                        end if;

                                  select nvl(sum(units),0)
                                  into l_dist_post_units
                                  from fa_mass_ext_retirements
                                  where book_type_code = g_book_type_code
                                  and   asset_id = l_asset_id
                                  and   review_status = 'POST'
                                  and   batch_name <> g_batch_name
                                  and   code_combination_id= dhrec.code_combination_id
                                  and   location_id = dhrec.location_id
                                  and   nvl(assigned_to,-99) = nvl(dhrec.assigned_to,-99);

                                  if dhrec.units_assigned > l_dist_post_units then

                                if (g_log_level_rec.statement_level) then
                                   fa_debug_pkg.add(l_calling_fn, 'units_assign > dist_post_units',
                                l_dist_post_units, p_log_level_rec => g_log_level_rec);
                                end if;

                                     l_dist_diff := dhrec.units_assigned - l_dist_post_units;
                                     if l_dist_diff <= l_diff then

                                        if not insert_details(
                                                l_2nd_asset_id,
                                                l_dist_diff,
                                                dhrec.code_combination_id,
                                                dhrec.location_id,
                                                dhrec.assigned_to,
                                                l_2nd_cost_retired,
                                                l_2nd_current_units) then

                                                raise dml_error;

                                        end if;
                                        if (g_log_level_rec.statement_level) then
                                            fa_debug_pkg.add(l_calling_fn,'insert details J',l_dist_diff, p_log_level_rec => g_log_level_rec);
                                        end if;

                                        message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                                        l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_dist_post_units);
                                        l_diff := l_diff - (dhrec.units_assigned - l_dist_post_units);

                                       end if; -- l_dist_diff
                                    end if; -- dhrec.units_assigned > ...
                                    fetch c_dh into dhrec;
                                 END LOOP;
                                 close c_dh;

                                if (g_log_level_rec.statement_level) then
                                   fa_debug_pkg.add(l_calling_fn, 'Occurences with no dist info, l_diff ',
                                   l_diff, p_log_level_rec => g_log_level_rec);
                                end if;

-- We've checked all distributions, now there are only occurences with
-- no distribution info left.
                                 if l_diff > 0 then
                                    open c_dh;
                                    fetch c_dh into dhrec;
                                    While (c_dh%FOUND and l_diff > 0) loop

                                       if dhrec.units_assigned > l_asset_post_units then
                                          l_dist_diff := dhrec.units_assigned - l_asset_post_units;
                                          if l_dist_diff <= l_diff then

                                             if not insert_details(
                                                l_2nd_asset_id,
                                                l_dist_diff,
                                                dhrec.code_combination_id,
                                                dhrec.location_id,
                                                dhrec.assigned_to,
                                                l_2nd_cost_retired,
                                                l_2nd_current_units) then

                                                raise dml_error;

                                             end if;
                                                if (g_log_level_rec.statement_level) then
                                                    fa_debug_pkg.add(l_calling_fn,'insert details K',l_dist_diff, p_log_level_rec => g_log_level_rec);
                                        end if;

                                             message_tbl(l_2nd_asset_number, num_msg, msg_tbl);
                                             l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_asset_post_units);
                                             l_diff := l_diff - (dhrec.units_assigned - l_asset_post_units);

                                         end if; -- l_dist_diff
                                  end if; -- dhrec.units_assigned > ...
                                  fetch c_dh into dhrec;
                               END LOOP;
                               close c_dh;
                            end if; -- l_diff >
                         end if; -- l_2nd_current_units >
-- a partial unit retirement

                      else -- expense_ccid is not null
-- bug 3161864

                        if (g_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'expense_ccid is not null',
                           '', p_log_level_rec => g_log_level_rec);
                        end if;

                        if l_2nd_current_units > l_asset_post_units then
                           select nvl(sum(units),0)
                           into l_dist_post_units
                           from fa_mass_ext_retirements
                           where book_type_code = g_book_type_code
                           and   asset_id = l_asset_id
                           and   review_status = 'POST'
                           and   batch_name <> g_batch_name
                           and   code_combination_id =
                                l_asset_dist_tbl(l_dist_count).expense_ccid
                           and   location_id =
                                l_asset_dist_tbl(l_dist_count).location_ccid
                           and   nvl(assigned_to,-99) =
                                nvl(l_asset_dist_tbl(l_dist_count).assigned_to,-99);
                           if l_asset_dist_tbl(l_dist_count).units_assigned >
                                l_dist_post_units then

                                if l_remaining_units <= (l_asset_dist_tbl(l_dist_count).units_assigned - l_dist_post_units) then
                                  if not insert_details(
                                    l_2nd_asset_id,
                                    l_remaining_units,
                                    l_asset_dist_tbl(l_dist_count).expense_ccid,
                                    l_asset_dist_tbl(l_dist_count).location_ccid,
                                    l_asset_dist_tbl(l_dist_count).assigned_to,
                                    l_2nd_cost_retired,
                                    l_2nd_current_units) then

                                    raise dml_error;
                                   end if;

                                   message_tbl(aurec.asset_number, num_msg, msg_tbl);

                                   l_remaining_units := 0;

                           else -- l_remaining_units > ...

                              if not insert_details(
                                l_2nd_asset_id,
                                l_asset_dist_tbl(l_dist_count).units_assigned - l_dist_post_units,
                                l_asset_dist_tbl(l_dist_count).expense_ccid,
                                l_asset_dist_tbl(l_dist_count).location_ccid,
                                l_asset_dist_tbl(l_dist_count).assigned_to,
                                l_2nd_cost_retired,
                                l_2nd_current_units) then

                                raise dml_error;
                              end if;
                              if (g_log_level_rec.statement_level) then
                                  l_slask := l_asset_dist_tbl(l_dist_count).units_assigned - l_dist_post_units;
                                    fa_debug_pkg.add(l_calling_fn,'insert details KK',l_slask, p_log_level_rec => g_log_level_rec);
                              end if;

                              message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                              l_remaining_units := l_remaining_units -
                                 (l_asset_dist_tbl(l_dist_count).units_assigned
                                 - l_dist_post_units);

                             end if; -- remaining_units..
                            end if; -- l_asset_dist_tbl...

                        end if; -- l_2nd_unit > ...skip asset if not meet crit.
                      end if; -- expense_ccid is null
                   end if; -- l_post_units > 0




                else -- units_assigned > l_remaining_units

                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'units_assigned > l_remain_units', l_remaining_units, p_log_level_rec => g_log_level_rec);
                  end if;

                  if l_post_units = 0 then




-- obtain distributions to partially retire from
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'outside...else, 11:units_assigned ', l_asset_dist_tbl(l_dist_count).units_assigned );
                     fa_debug_pkg.add(l_calling_fn, 'outside...else, 11: asset ', l_asset_id, p_log_level_rec => g_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'outside...else, 11: asset ', l_2nd_asset_id, p_log_level_rec => g_log_level_rec);
                  end if;

                        open c_dh;
                        fetch c_dh into dhrec;
                        While (c_dh%FOUND and l_remaining_units > 0) loop


                          if dhrec.units_assigned >= l_remaining_units then

                             if (g_log_level_rec.statement_level) then
                              fa_debug_pkg.add(l_calling_fn, 'Before Insert details B, units',
                                l_asset_dist_tbl(l_dist_count).units_assigned);
                             end if;

                       -- insert partial unit retirement

                             if not insert_details(
                                l_2nd_asset_id,
                                l_remaining_units,
                                dhrec.code_combination_id,
                                dhrec.location_id,
                                dhrec.assigned_to,
                                l_2nd_cost_retired,
                                l_2nd_current_units) then

                               raise dml_error;

                             end if;
                             if (g_log_level_rec.statement_level) then
                                                    fa_debug_pkg.add(l_calling_fn,'insert details L',l_remaining_units, p_log_level_rec => g_log_level_rec);
                             end if;

                              message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                             if (g_log_level_rec.statement_level) then
                                     fa_debug_pkg.add(l_calling_fn,
                                        'Outside.., remaining units',
                                        0 , p_log_level_rec => g_log_level_rec);
                             end if;

                             l_remaining_units := 0;
                           else  -- units_assigned


-- insert partial unit retirement

                             if (g_log_level_rec.statement_level) then
                              fa_debug_pkg.add(l_calling_fn, 'Before Insert details C, units',
                                l_asset_dist_tbl(l_dist_count).units_assigned);
                             end if;

                             if not insert_details(
                                l_2nd_asset_id,
                                dhrec.units_assigned,
                                dhrec.code_combination_id,
                                dhrec.location_id,
                                dhrec.assigned_to,
                                l_2nd_cost_retired,
                                l_2nd_current_units) then

                                raise dml_error;

                              end if;
                              if (g_log_level_rec.statement_level) then
                                    fa_debug_pkg.add(l_calling_fn,'insert details M', dhrec.units_assigned, p_log_level_rec => g_log_level_rec);
                              end if;
                              message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                              l_remaining_units := l_remaining_units - dhrec.units_assigned;
                               if (g_log_level_rec.statement_level) then
                                     fa_debug_pkg.add(l_calling_fn,
                                        'Outside.., remaining units',
                                        l_remaining_units , p_log_level_rec => g_log_level_rec);
                               end if;


                           end if;
                           fetch c_dh into dhrec;
                        end loop; -- dhloop
                        close c_dh;

                    else  -- l_post_units >  0


                        select nvl(sum(units),0)
                        into l_asset_post_units
                        from fa_mass_ext_retirements
                        where book_type_code = g_book_type_code
                        and   asset_id = l_asset_id
                        and   review_status = 'POST'
                        and   batch_name <> g_batch_name;

-- when expense_ccid is null we must provide the distribution info
-- for the insert.
                        if l_asset_dist_tbl(l_dist_count).expense_ccid is null then

                           if l_2nd_current_units > l_asset_post_units then
                                l_diff := l_2nd_current_units - l_asset_post_units;
                                open c_dh;
                                fetch c_dh into dhrec;
                                While (c_dh%FOUND and l_remaining_units > 0) loop


                                   select nvl(sum(units),0)
                                   into l_dist_post_units
                                   from fa_mass_ext_retirements
                                   where book_type_code = g_book_type_code
                                   and   asset_id = l_asset_id
                                   and   review_status = 'POST'
                                   and   batch_name <> g_batch_name
                                   and   code_combination_id= dhrec.code_combination_id
                                   and   location_id = dhrec.location_id
                                   and   nvl(assigned_to,-99) = nvl(dhrec.assigned_to,-99);


                                   if dhrec.units_assigned > l_dist_post_units then
                                      l_dist_diff := dhrec.units_assigned - l_dist_post_units;
                                      if l_dist_diff <= l_remaining_units then

                                      if not insert_details(
                                        l_2nd_asset_id,
                                        l_dist_diff,
                                        dhrec.code_combination_id,
                                        dhrec.location_id,
                                        dhrec.assigned_to,
                                        l_2nd_cost_retired,
                                        l_2nd_current_units) then

                                                raise dml_error;

                                        end if;
                                                if (g_log_level_rec.statement_level) then
                                                    fa_debug_pkg.add(l_calling_fn,'insert details M',l_dist_diff, p_log_level_rec => g_log_level_rec);
                                        end if;

                                        message_tbl(l_2nd_asset_number, num_msg, msg_tbl);
                                        l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_dist_post_units);
                                        l_diff := l_diff - (dhrec.units_assigned - l_dist_post_units);

                                     else -- l_dist_diff
-- rn here....

                                             if not insert_details(
                                                l_2nd_asset_id,
                                                l_remaining_units,
                                                dhrec.code_combination_id,
                                                dhrec.location_id,
                                                dhrec.assigned_to,
                                                l_2nd_cost_retired,
                                                l_2nd_current_units) then

                                                raise dml_error;

                                              end if;
                                              if (g_log_level_rec.statement_level) then
                                                    fa_debug_pkg.add(l_calling_fn,'insert details O',l_dist_diff, p_log_level_rec => g_log_level_rec);
                                              end if;
                                              message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                                              l_remaining_units := 0;
                                              l_diff := 0;

                                       end if; -- l_dist_diff

                                    end if; -- dhrec.units_assigned > ...
                                    fetch c_dh into dhrec;
                                 END LOOP;
                                 close c_dh;



-- We've checked all distributions, now there are only occurences with
-- no   -distribution info left.
-- changed for bug 3880664
--              if l_remaining_units > 0 then
                                if l_diff > 0 then

                                    open c_dh;
                                    fetch c_dh into dhrec;
-- changed for bug 3880664
-- While (c_dh%FOUND and l_remaining_units > 0) loop
                                    While (c_dh%FOUND and l_diff > 0) loop

                                        if dhrec.units_assigned > l_asset_post_units then
                                           l_dist_diff := dhrec.units_assigned - l_asset_post_units;
                                           if l_dist_diff <= l_remaining_units then

                                             if not insert_details(
                                                l_2nd_asset_id,
                                                l_dist_diff,
                                                dhrec.code_combination_id,
                                                dhrec.location_id,
                                                dhrec.assigned_to,
                                                l_2nd_cost_retired,
                                                l_2nd_current_units) then

                                                raise dml_error;

                                              end if;
                                              if (g_log_level_rec.statement_level) then
                                                    fa_debug_pkg.add(l_calling_fn,'insert details O',l_dist_diff, p_log_level_rec => g_log_level_rec);
                                              end if;

                                              message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                                              l_remaining_units := l_remaining_units - (dhrec.units_assigned - l_asset_post_units);
                                              l_diff := l_diff - (dhrec.units_assigned - l_asset_post_units);


                                            else -- l_dist_diff

-- rn here....

                                             if not insert_details(
                                                l_2nd_asset_id,
                                                l_remaining_units,
                                                dhrec.code_combination_id,
                                                dhrec.location_id,
                                                dhrec.assigned_to,
                                                l_2nd_cost_retired,
                                                l_2nd_current_units) then

                                                raise dml_error;

                                              end if;
                                              if (g_log_level_rec.statement_level) then
                                                    fa_debug_pkg.add(l_calling_fn,'insert details O',l_dist_diff, p_log_level_rec => g_log_level_rec);
                                              end if;


                                              message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                                              l_remaining_units := 0;
                                              l_diff := 0;
-- rn end..

                                            end if; -- l_dist_diff
                                         end if; -- dhrec.units_assigned > ...
                                         fetch c_dh into dhrec;
                                      END LOOP;
                                      close c_dh;

                                  end if; -- l_remaining_units >
                                end if; -- l_2nd_current_units >

-- a partial unit retirement

                      else -- expense_ccid is not null
-- bug 3161864

                        if l_2nd_current_units > l_asset_post_units then

                           select nvl(sum(units),0)
                           into l_dist_post_units
                           from fa_mass_ext_retirements
                           where book_type_code = g_book_type_code
                           and   asset_id = l_asset_id
                           and   review_status = 'POST'
                           and   batch_name <> g_batch_name
                           and   code_combination_id =
                                l_asset_dist_tbl(l_dist_count).expense_ccid
                           and   location_id =
                                l_asset_dist_tbl(l_dist_count).location_ccid
                           and   nvl(assigned_to,-99) =
                                nvl(l_asset_dist_tbl(l_dist_count).assigned_to,-99);

                           if l_asset_dist_tbl(l_dist_count).units_assigned >
                                l_dist_post_units then

                                if l_remaining_units <= (l_asset_dist_tbl(l_dist_count).units_assigned - l_dist_post_units) then

                                  if not insert_details(
                                    l_2nd_asset_id,
                                    l_remaining_units,
                                    l_asset_dist_tbl(l_dist_count).expense_ccid,
                                    l_asset_dist_tbl(l_dist_count).location_ccid,
                                    l_asset_dist_tbl(l_dist_count).assigned_to,
                                    l_2nd_cost_retired,
                                    l_2nd_current_units) then

                                        raise dml_error;
                                   end if;

                                   message_tbl(aurec.asset_number, num_msg, msg_tbl);
                                   l_remaining_units := 0;

                                 else -- l_remaining_units > ...

                                   if not insert_details(
                                     l_2nd_asset_id,
                                     l_asset_dist_tbl(l_dist_count).units_assigned - l_dist_post_units,
                                     l_asset_dist_tbl(l_dist_count).expense_ccid,
                                     l_asset_dist_tbl(l_dist_count).location_ccid,
                                     l_asset_dist_tbl(l_dist_count).assigned_to,
                                     l_2nd_cost_retired,
                                     l_2nd_current_units) then

                                        raise dml_error;
                                   end if;
                                   if (g_log_level_rec.statement_level) then

                                        l_slask :=
                                    l_asset_dist_tbl(l_dist_count).units_assigned - l_dist_post_units;
                                        fa_debug_pkg.add(l_calling_fn,'insert details P',l_slask, p_log_level_rec => g_log_level_rec);
                                    end if;

                                    message_tbl(l_2nd_asset_number, num_msg, msg_tbl);

                                    l_remaining_units := l_remaining_units -
                                    (l_asset_dist_tbl(l_dist_count).units_assigned - l_dist_post_units);

                             end if; -- l_remaining_units...
                            end if; -- l_asset_dist_tbl...

                        end if; -- l_2nd_unit > ...skip asset if not meet crit.

                     end if; -- expense_ccid

                 end if; -- post_units

               end if; -- units_assigned

             END LOOP;   -- l_asset_dist_tbl


           end if; -- check_extended_life
        end if; -- check_addition_retirement

        FETCH qual_ass_by_asset_number_out
          INTO l_2nd_Asset_Id,
               l_2nd_asset_number,
               l_2nd_dpis,
               l_2nd_Cost_Retired,
               l_2nd_current_units;

     End loop; -- end qual loop
     close qual_ass_by_asset_number_out;



   End if;  -- p_extend_search = yes
-- Done allocating units.

   if (g_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn,
                        'Done allocating units, remaining units',
                        l_remaining_units , p_log_level_rec => g_log_level_rec);
   end if;


        -- Now Update status to the mass retirements batch
   If l_remaining_units > 0 then -- not all units have been prorated. Abort.
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'Update status',l_remaining_units , p_log_level_rec => g_log_level_rec);
        end if;

        Delete from fa_mass_ext_retirements
        Where batch_name = g_batch_name;

        Update fa_mass_retirements
        Set status = 'ON_HOLD'
        Where mass_retirement_id = G_Mass_Retirement_id;

        p_suxess_no := 0;
        p_fail_no   := 1;

        msg_tbl.delete;

        Write_Message('                ',
                      'FA_MASSRET_NOT_ENOUGH_UNITS',
                      l_remaining_units, g_units);

--        fa_srvr_msg.add_message(name => 'FA_MASSRET_NOT_ENOUGH_UNITS',
--                              calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);


   Elsif l_remaining_units <= 0 then
-- Not enough units provided, assets have been
-- inserted into fa_mass_ext_retirements
-- but will not get any units assigned for certain of these rows.
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'Update status <= 0 ',l_remaining_units , p_log_level_rec => g_log_level_rec);
        end if;


-- rn Delete review_status have been set in initial insert.

        Delete from fa_mass_ext_retirements
        Where batch_name = g_batch_name
        And review_status = 'DELETE';

-- rn print messages to outfile now.

        FOR i in 1 .. msg_tbl.COUNT LOOP
             p_suxess_no := p_suxess_no + 1;
             Write_Message(msg_tbl(i).asset_number,'FA_SHARED_INSERT_DEBUG',
                        '','');

        END LOOP;

        Update fa_mass_retirements
        Set status = 'CREATED_RET'
        Where mass_retirement_id = G_Mass_Retirement_id;

   End if; -- remaining_units.



 return true;

Exception
  when dml_error then
      error := substrb(sqlerrm,1,80);
      fa_debug_pkg.add(
      'Allocate_Units',
        error,
        '', p_log_level_rec => g_log_level_rec);
     return false;
  when others then
      error := substrb(sqlerrm,1,80);
      fa_debug_pkg.add(
      'Allocate_Units',
        error,
        '', p_log_level_rec => g_log_level_rec);
     return false;

END Allocate_units;



------------------------------------------------------------------------------

-- This is a new procedure which will determine all candidate assets
-- prorate the COR and PROCEEDS amounts and insert them into the
-- mass retirements details table.

PROCEDURE Create_Mass_Retirements
               (errbuf                  OUT NOCOPY      VARCHAR2,
                retcode                 OUT NOCOPY      NUMBER,
                p_mass_retirement_id    IN              NUMBER,
                p_mode                  IN              VARCHAR2,
                p_extend_search         IN              VARCHAR2) IS

   -- local variables
   l_string      varchar2(250);

   TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

   -- Local Variables holding Asset Information
   l_Asset_Id                  num_tbl;
   l_Asset_Number              v30_tbl;
   l_Cost_Retired              num_tbl;

   -- Local Variables holding Asset Subcomponent Information
   l_SC_Asset_Id               num_tbl;
   l_SC_Asset_Number           v30_tbl;
   l_SC_Cost_Retired           fa_books.cost%TYPE;

   -- used for bulk fetch
   l_batch_size       NUMBER;
   l_loop_count       NUMBER;

   -- Control Variables
   l_Subcomponent_Excluded     VARCHAR2(1);
   l_parent_asset_id           num_tbl;      -- table for bulk fetch

   l_candidate_asset_id        num_tbl;
   l_candidate_cost_retired    num_tbl;


   l_dist_units_tbl             num_tbl;
   l_distribution_id_tbl        num_tbl;
   l_dist_units         number;
   l_distribution_id    number;

   -- used for proration
   l_Prorated_Proceeds_Of_Sale     num_tbl;
   l_Prorated_Cost_Of_Removal      num_tbl;
   l_Total_Cost_Retired            NUMBER:=0;
   l_Total_Count_Retired           NUMBER:=0;
   l_Running_Count_Retired         NUMBER:=0;
   l_Running_Prorated_POS          NUMBER:=0;
   l_Running_Prorated_Cost         NUMBER:=0;
   l_Running_Asset_Count           NUMBER:=0;


   -- moved from do_ret
   l_Acct_Split        VARCHAR2(1);
   l_Emp_Split         VARCHAR2(1);
   l_Loc_Split         VARCHAR2(1);
   l_Null_Segment_Flag VARCHAR2(1);
   l_Reason_Code       VARCHAR2(30);

   l_calling_fn        varchar2(35) := 'FA_MASS_RET_PKG.allocate_assets';
   l_msg_count         number;
   l_msg_data          varchar2(512);

   l_failure_count     NUMBER := 0;

   done_exc            exception;
   error_found         exception;



   CURSOR mass_retirement IS
    SELECT fmr.mass_retirement_id,
           fmr.book_type_code,
           fmr.retirement_date,
           substrb(fmr.description, 1, 30),
           fmr.retire_subcomponents_flag,
           fmr.status,
           nvl(fmr.proceeds_of_sale,0),
           nvl(fmr.cost_of_removal,0) ,
           fmr.retirement_type_code,
           fmr.asset_type,
           fmr.location_id,
           fmr.employee_id,
           fmr.category_id,
           fmr.asset_key_id,
           fmr.from_asset_number,
           fmr.to_asset_number,
           fmr.from_date_placed_in_service,
           fmr.to_date_placed_in_service,
           fmr.model_number,
           fmr.serial_number,
           fmr.tag_number,
           fmr.manufacturer_name,
           fmr.units_to_retire,
           fmr.attribute1,
           fmr.attribute2,
           fmr.attribute3,             fmr.attribute4,
           fmr.attribute5,             fmr.attribute6,
           fmr.attribute7,             fmr.attribute8,
           fmr.attribute9,             fmr.attribute10,
           fmr.attribute11,            fmr.attribute12,
           fmr.attribute13,            fmr.attribute14,
           fmr.attribute15,            fmr.attribute_category_code,
           fmr.segment1_low,           fmr.segment2_low,
           fmr.segment3_low,           fmr.segment4_low,
           fmr.segment5_low,           fmr.segment6_low,
           fmr.segment7_low,           fmr.segment8_low,
           fmr.segment9_low,           fmr.segment10_low,
           fmr.segment11_low,          fmr.segment12_low,
           fmr.segment13_low,          fmr.segment14_low,
           fmr.segment15_low,          fmr.segment16_low,
           fmr.segment17_low,          fmr.segment18_low,
           fmr.segment19_low,          fmr.segment20_low,
           fmr.segment21_low,          fmr.segment22_low,
           fmr.segment23_low,          fmr.segment24_low,
           fmr.segment25_low,          fmr.segment26_low,
           fmr.segment27_low,          fmr.segment28_low,
           fmr.segment29_low,          fmr.segment30_low,
           fmr.segment1_high,          fmr.segment2_high,
           fmr.segment3_high,          fmr.segment4_high,
           fmr.segment5_high,          fmr.segment6_high,
           fmr.segment7_high,          fmr.segment8_high,
           fmr.segment9_high,          fmr.segment10_high,
           fmr.segment11_high,         fmr.segment12_high,
           fmr.segment13_high,         fmr.segment14_high,
           fmr.segment15_high,         fmr.segment16_high,
           fmr.segment17_high,         fmr.segment18_high,
           fmr.segment19_high,         fmr.segment20_high,
           fmr.segment21_high,         fmr.segment22_high,
           fmr.segment23_high,         fmr.segment24_high,
           fmr.segment25_high,         fmr.segment26_high,
           fmr.segment27_high,         fmr.segment28_high,
           fmr.segment29_high,         fmr.segment30_high,
           sob.currency_code,
           fbc.book_class,
           fmr.from_cost,
           fmr.to_cost,
           fmr.include_fully_rsvd_flag,
           fmr.group_asset_id,  -- crl, no reason to break out
           fmr.group_association
      FROM fa_mass_retirements fmr,
           fa_book_controls fbc,
           gl_sets_of_books sob
     WHERE fmr.mass_retirement_id = p_Mass_Retirement_Id
       AND fmr.book_type_code     = fbc.book_type_code
       AND fbc.set_of_books_id    = sob.set_of_books_id;


   CURSOR qual_ass_by_asset_number IS
    SELECT /* ORDERED INDEX (FAB FA_BOOKS_N2) */
           faa.asset_id,
           faa.asset_number,
           fab.cost,
           faa.current_units
      FROM fa_books         fab,
           fa_book_controls fbc,
           fa_additions_b   faa
     WHERE faa.asset_id = fab.asset_id
       AND (faa.asset_key_ccid = G_Asset_Key_Id
             OR G_Asset_Key_Id IS NULL)
       AND faa.asset_category_id = nvl(G_Category_Id,faa.asset_category_id)
       AND fab.cost >= nvl(G_From_Cost,fab.cost)
       AND fab.cost <= nvl(G_To_Cost,fab.cost)
       -- crl - no reason to make this conditional
       AND ((G_group_asset_id = -1 and -- group change
             fab.group_asset_id is null) OR -- group change
            (G_group_asset_id = -99) OR -- group change
            (G_group_asset_id > 0 and -- group change
             nvl(fab.group_asset_id, -999) = g_group_asset_id)) -- group change
       AND nvl(fab.period_counter_fully_reserved,-99999) =
          decode(G_Fully_Rsvd_Flag,
               'YES',fab.period_counter_fully_reserved,
               'NO',-99999,
               nvl(fab.period_counter_fully_reserved,-99999))
       AND faa.asset_number                >=
           nvl(G_From_Asset_Number, faa.asset_number)
       AND faa.asset_number                <=
           nvl(G_To_Asset_Number,  faa.asset_number)
       AND fab.date_placed_in_service
              BETWEEN nvl(G_From_DPIS,fab.date_placed_in_service-1)
                  AND nvl(G_To_DPIS  ,fab.date_placed_in_service+1)
       AND (faa.model_number = G_model_number
                OR G_model_number IS NULL)
       AND (faa.serial_number  = G_serial_number
                OR G_serial_number IS NULL)
       AND (faa.tag_number      = G_tag_number
                OR G_tag_number IS NULL)
       AND (faa.manufacturer_name = G_manufacturer_name
                OR G_manufacturer_name IS NULL)
       AND fab.book_type_code = G_Book_Type_Code -- 8264324 fbc.book_type_code
       AND fbc.date_ineffective is null
       AND EXISTS (SELECT null
                     FROM fa_distribution_history fad,
                          gl_code_combinations    gcc
                    WHERE fad.asset_id = faa.asset_id
                      AND fad.code_combination_id = gcc.code_combination_id
                      AND (fad.assigned_to = G_Employee_Id
                           OR G_Employee_Id IS NULL)
                      AND (fad.location_id = G_Location_Id
                           OR G_Location_Id IS NULL)
                      AND fad.date_ineffective IS NULL
                      AND (gcc.segment1 BETWEEN G_Segment1_Low
                                            AND G_Segment1_High
                           OR G_Segment1_Low IS NULL)
                      AND (gcc.segment2 BETWEEN G_Segment2_Low
                                            AND G_Segment2_High
                           OR G_Segment2_Low IS NULL)
                      AND (gcc.segment3 BETWEEN G_Segment3_Low
                                            AND G_Segment3_High
                           OR G_Segment3_Low IS NULL)
                      AND (gcc.segment4 BETWEEN G_Segment4_Low
                                            AND G_Segment4_High
                           OR G_Segment4_Low IS NULL)
                      AND (gcc.segment5 BETWEEN G_Segment5_Low
                                            AND G_Segment5_High
                           OR G_Segment5_Low IS NULL)
                      AND (gcc.segment6 BETWEEN G_Segment6_Low
                                            AND G_Segment6_High
                           OR G_Segment6_Low IS NULL)
                      AND (gcc.segment7 BETWEEN G_Segment7_Low
                                            AND G_Segment7_High
                           OR G_Segment7_Low IS NULL)
                      AND (gcc.segment8 BETWEEN G_Segment8_Low
                                            AND G_Segment8_High
                           OR G_Segment8_Low IS NULL)
                      AND (gcc.segment9 BETWEEN G_Segment9_Low
                                            AND G_Segment9_High
                           OR G_Segment9_Low IS NULL)
                      AND (gcc.segment10 BETWEEN G_Segment10_Low
                                             AND G_Segment10_High
                           OR G_Segment10_Low IS NULL)
                      AND (gcc.segment11 BETWEEN G_Segment11_Low
                                             AND G_Segment11_High
                           OR G_Segment11_Low IS NULL)
                      AND (gcc.segment12 BETWEEN G_Segment12_Low
                                             AND G_Segment12_High
                           OR G_Segment12_Low IS NULL)
                      AND (gcc.segment13 BETWEEN G_Segment13_Low
                                             AND G_Segment13_High
                           OR G_Segment13_Low IS NULL)
                      AND (gcc.segment14 BETWEEN G_Segment14_Low
                                             AND G_Segment14_High
                           OR G_Segment14_Low IS NULL)
                      AND (gcc.segment15 BETWEEN G_Segment15_Low
                                             AND G_Segment15_High
                           OR G_Segment15_Low IS NULL)
                      AND (gcc.segment16 BETWEEN G_Segment16_Low
                                             AND G_Segment16_High
                           OR G_Segment16_Low IS NULL)
                      AND (gcc.segment17 BETWEEN G_Segment17_Low
                                             AND G_Segment17_High
                           OR G_Segment17_Low IS NULL)
                      AND (gcc.segment18 BETWEEN G_Segment18_Low
                                             AND G_Segment18_High
                           OR G_Segment18_Low IS NULL)
                      AND (gcc.segment19 BETWEEN G_Segment19_Low
                                             AND G_Segment19_High
                           OR G_segment19_Low IS NULL)
                      AND (gcc.segment20 BETWEEN G_Segment20_Low
                                             AND G_Segment20_High
                           OR G_segment20_Low IS NULL)
                      AND (gcc.segment21 BETWEEN G_Segment21_Low
                                             AND G_Segment21_High
                           OR G_segment21_Low IS NULL)
                      AND (gcc.segment22 BETWEEN G_Segment22_Low
                                             AND G_Segment22_High
                           OR G_segment22_Low IS NULL)
                      AND (gcc.segment23 BETWEEN G_Segment23_Low
                                             AND G_Segment23_High
                           OR G_segment23_Low IS NULL)
                      AND (gcc.segment24 BETWEEN G_Segment24_Low
                                             AND G_Segment24_High
                           OR G_segment24_Low IS NULL)
                      AND (gcc.segment25 BETWEEN G_Segment25_Low
                                             AND G_Segment25_High
                           OR G_segment25_Low IS NULL)
                      AND (gcc.segment26 BETWEEN G_Segment26_Low
                                             AND G_Segment26_High
                           OR G_segment26_Low IS NULL)
                      AND (gcc.segment27 BETWEEN G_Segment27_Low
                                             AND G_Segment27_High
                           OR G_segment27_Low IS NULL)
                      AND (gcc.segment28 BETWEEN G_Segment28_Low
                                             AND G_Segment28_High
                           OR G_segment28_Low IS NULL)
                      And (gcc.segment29 BETWEEN G_Segment29_Low
                                             AND G_Segment29_High
                           OR G_segment29_Low IS NULL)
                      AND (gcc.segment30 BETWEEN G_Segment30_Low
                                             AND G_Segment30_High
                           OR G_segment30_Low IS NULL))
       AND (faa.asset_type = G_Asset_Type OR G_Asset_Type IS NULL)
       AND faa.asset_type IN ('CIP','CAPITALIZED','EXPENSED')
       -- YYOON 12/13/01: Performance Bug#2134816: Changed driving table from fa_books to fa_book_controls
       AND fbc.book_type_code = G_Book_Type_Code
       --AND fab.date_ineffective IS NULL
       AND fab.TRANSACTION_HEADER_ID_OUT IS NULL --bug 8264324
     ORDER BY fab.date_placed_in_service, faa.asset_number;


   -- *******************************************************************************
   -- Added as fix to BG320179. Get the subcomponents, but ensure that they have not
   -- already been chosen by the original criteria from qualified assets.
   -- *******************************************************************************
   CURSOR subcomponents (p_parent_asset_id number) IS
   SELECT asset_id,
          asset_number,
          parent_asset_id,
          current_units
     FROM fa_additions_b
    WHERE parent_asset_id is not null
      AND parent_asset_id = p_parent_asset_id
   MINUS
   SELECT faa.asset_id, faa.asset_number, faa.parent_asset_id, faa.current_units
   FROM fa_books         fab,
        fa_additions_b   faa
    WHERE faa.parent_asset_id is not null
      AND faa.parent_asset_id = p_parent_asset_id
      AND  faa.asset_id = fab.asset_id
               AND (faa.asset_key_ccid = G_Asset_Key_Id OR G_Asset_Key_Id IS NULL)
               AND faa.asset_category_id = nvl(G_Category_Id,faa.asset_category_id)
               AND fab.period_counter_fully_retired IS NULL
               AND ((G_group_asset_id = -1 and -- group change
                     fab.group_asset_id is null) OR -- group change
                    (G_group_asset_id = -99) OR -- group change
                    (G_group_asset_id > 0 and -- group change
                     nvl(fab.group_asset_id, -999) = g_group_asset_id)) -- group change
               AND faa.asset_number                >=
                   nvl(G_From_Asset_Number, faa.asset_number)
               AND faa.asset_number                <=
                   nvl(G_To_Asset_Number,  faa.asset_number)
               AND fab.date_placed_in_service
              BETWEEN nvl(G_From_DPIS,fab.date_placed_in_service-1)
                  AND nvl(G_To_DPIS  ,fab.date_placed_in_service+1)
               AND (faa.model_number = G_model_number
                        OR G_model_number IS NULL)
               AND (faa.serial_number  = G_serial_number
                        OR G_serial_number IS NULL)
               AND (faa.tag_number      = G_tag_number
                        OR G_tag_number IS NULL)
               AND (faa.manufacturer_name = G_manufacturer_name
                        OR G_manufacturer_name IS NULL)
               AND NOT EXISTS (SELECT null
                                 FROM FA_TRANSACTION_HEADERS fth
                                WHERE fth.asset_id = fab.asset_id
                                  AND fth.book_type_code = fab.book_type_code
                                  AND (fth.transaction_date_entered > G_Retirement_Date and
                                       fth.transaction_type_code not in ('FULL RETIREMENT','REINSTATEMENT')))
               AND faa.asset_id in (SELECT faa2.asset_id
                                      FROM fa_additions_b faa2,
                                           gl_code_combinations gcc,
                                           fa_distribution_history fad
                                      WHERE fad.asset_id = faa2.asset_id
                                       AND fad.code_combination_id = gcc.code_combination_id
                                       AND (fad.assigned_to = G_Employee_Id
                                            OR G_Employee_Id IS NULL)
                                       AND (fad.location_id = G_Location_ID
                                            OR G_Location_Id IS NULL)
                                       AND fad.date_ineffective IS NULL
                                       AND (gcc.segment1 BETWEEN G_Segment1_Low
                                                             AND G_Segment1_High
                                            OR G_Segment1_Low IS NULL)
                                       AND (gcc.segment2 BETWEEN G_Segment2_Low
                                                             AND G_Segment2_High
                                            OR G_Segment2_Low IS NULL)
                                       AND (gcc.segment3 BETWEEN G_Segment3_Low
                                                             AND G_Segment3_High
                                            OR G_Segment3_Low IS NULL)
                                       AND (gcc.segment4 BETWEEN G_Segment4_Low
                                                             AND G_Segment4_High
                                            OR G_Segment4_Low IS NULL)
                                       AND (gcc.segment5 BETWEEN G_Segment5_Low
                                                             AND G_Segment5_High
                                            OR G_Segment5_Low IS NULL)
                                       AND (gcc.segment6 BETWEEN G_Segment6_Low
                                                             AND G_Segment6_High
                                            OR G_Segment6_Low IS NULL)
                                       AND (gcc.segment7 BETWEEN G_Segment7_Low
                                                             AND G_Segment7_High
                                            OR G_Segment7_Low IS NULL)
                                       AND (gcc.segment8 BETWEEN G_Segment8_Low
                                                             AND G_Segment8_High
                                            OR G_Segment8_Low IS NULL)
                                       AND (gcc.segment9 BETWEEN G_Segment9_Low
                                                             AND G_Segment9_High
                                            OR G_Segment9_Low IS NULL)
                                       AND (gcc.segment10 BETWEEN G_Segment10_Low
                                                              AND G_Segment10_High
                                            OR G_Segment10_Low IS NULL)
                                       AND (gcc.segment11 BETWEEN G_Segment11_Low
                                                              AND G_Segment11_High
                                            OR G_Segment11_Low IS NULL)
                                       AND (gcc.segment12 BETWEEN G_Segment12_Low
                                                              AND G_Segment12_High
                                            OR G_Segment12_Low IS NULL)
                                       AND (gcc.segment13 BETWEEN G_Segment13_Low
                                                              AND G_Segment13_High
                                            OR G_Segment13_Low IS NULL)
                                       AND (gcc.segment14 BETWEEN G_Segment14_Low
                                                              AND G_Segment14_High
                                            OR G_Segment14_Low IS NULL)
                                       AND (gcc.segment15 BETWEEN G_Segment15_Low
                                                              AND G_Segment15_High
                                            OR G_Segment15_Low IS NULL)
                                       AND (gcc.segment16 BETWEEN G_Segment16_Low
                                                              AND G_Segment16_High
                                            OR G_Segment16_Low IS NULL)
                                       AND (gcc.segment17 BETWEEN G_Segment17_Low
                                                              AND G_Segment17_High
                                            OR G_Segment17_Low IS NULL)
                                       AND (gcc.segment18 BETWEEN G_Segment18_Low
                                                              AND G_Segment18_High
                                            OR G_Segment18_Low IS NULL)
                                       AND (gcc.segment19 BETWEEN G_Segment19_Low
                                                              AND G_Segment19_High
                                            OR G_segment19_Low IS NULL)
                                       AND (gcc.segment20 BETWEEN G_Segment20_Low
                                                              AND G_Segment20_High
                                            OR G_segment20_Low IS NULL)
                                       AND (gcc.segment21 BETWEEN G_Segment21_Low
                                                              AND G_Segment21_High
                                            OR G_segment21_Low IS NULL)
                                       AND (gcc.segment22 BETWEEN G_Segment22_Low
                                                              AND G_Segment22_High
                                            OR G_segment22_Low IS NULL)
                                       AND (gcc.segment23 BETWEEN G_Segment23_Low
                                                              AND G_Segment23_High
                                            OR G_segment23_Low IS NULL)
                                       AND (gcc.segment24 BETWEEN G_Segment24_Low
                                                              AND G_Segment24_High
                                            OR G_segment24_Low IS NULL)
                                       AND (gcc.segment25 BETWEEN G_Segment25_Low
                                                              AND G_Segment25_High
                                            OR G_segment25_Low IS NULL)
                                       AND (gcc.segment26 BETWEEN G_Segment26_Low
                                                              AND G_Segment26_High
                                            OR G_segment26_Low IS NULL)
                                       AND (gcc.segment27 BETWEEN G_Segment27_Low
                                                              AND G_Segment27_High
                                            OR G_segment27_Low IS NULL)
                                       AND (gcc.segment28 BETWEEN G_Segment28_Low
                                                              AND G_Segment28_High
                                            OR G_segment28_Low IS NULL)
                                       And (gcc.segment29 BETWEEN G_Segment29_Low
                                                              AND G_Segment29_High
                                            OR G_segment29_Low IS NULL)
                                       AND (gcc.segment30 BETWEEN G_Segment30_Low
                                                              AND G_Segment30_High
                                            OR G_segment30_Low IS NULL))
               AND (FAA.asset_type = G_Asset_Type OR G_Asset_Type IS NULL)
               AND faa.asset_type IN ('CIP','CAPITALIZED','EXPENSED')
               AND fab.book_type_code = G_Book_Type_Code
               AND fab.date_ineffective IS NULL;

   CURSOR subcomponent_detail (p_asset_id NUMBER) IS
   SELECT fab.cost
     FROM fa_additions_b   faa,
          fa_books         fab
    WHERE faa.asset_id = fab.asset_id
      AND faa.asset_id = p_asset_id
      AND fab.period_counter_fully_retired IS NULL
      AND faa.asset_type IN ('CIP','CAPITALIZED','EXPENSED')
      AND fab.book_type_code = G_Book_Type_Code
      And fab.date_ineffective IS NULL;


   CURSOR mass_ret_assets (p_batch_name varchar2) IS
   SELECT asset_id,
          cost_retired
     FROM fa_mass_ext_retirements
    WHERE batch_name = p_batch_name;

   /* Bug 8647381 - Starts */
   CURSOR c_recognize_gain_loss(p_asset_id NUMBER) IS
   SELECT fab2.recognize_gain_loss
     FROM fa_books fab1, fa_books fab2
    WHERE fab1.book_type_code = G_Book_Type_Code
      AND fab1.asset_id = p_asset_id
      AND fab1.date_ineffective IS NULL
      AND fab2.asset_id = fab1.group_asset_id
      AND fab2.book_type_code = fab1.book_type_code
      AND fab2.date_ineffective IS NULL;

 	l_recognize_gain_loss VARCHAR2(5);
 	/* Bug 8647381 - Ends */


l_candidate_units       num_tbl;
l_dist_count            number;
l_asset_dist_tbl        FA_API_TYPES.asset_dist_tbl_type;
l_sc_units              num_tbl;
l_current_units         num_tbl;
l_total_dist_cost       number;
suxess_no               number;
fail_no                 number;

BEGIN -- Allocate Assets


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;

   G_release := fa_cache_pkg.fazarel_release;

   FA_SRVR_MSG.Init_Server_Message;
   FA_DEBUG_PKG.Initialize;

   if p_mode <> 'BATCH' then


     FND_FILE.put(FND_FILE.output,'');
     FND_FILE.new_line(FND_FILE.output,1);

     fnd_message.set_name('OFA', 'FAMRET');
     l_string := fnd_message.get;

     FND_FILE.put(FND_FILE.output,l_string);
     FND_FILE.put(FND_FILE.output,'');
     FND_FILE.new_line(FND_FILE.output,1);
     FND_FILE.put(FND_FILE.output,'');
     FND_FILE.new_line(FND_FILE.output,1);

   -- dump out the headings
     fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_COLUMN');
     l_string := fnd_message.get;

     FND_FILE.put(FND_FILE.output,l_string);
     FND_FILE.new_line(FND_FILE.output,1);

     fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_LINE');
     l_string := fnd_message.get;

     FND_FILE.put(FND_FILE.output,l_string);
     FND_FILE.new_line(FND_FILE.output,1);
   end if;

   OPEN mass_retirement;
   FETCH mass_retirement
    INTO G_Mass_Retirement_Id,
         G_Book_Type_Code,
         G_Retirement_Date,
         G_Transaction_Name,
         G_Retire_Subcomponents,
         G_Status,
         G_Proceeds_Of_Sale,
         G_Cost_Of_Removal,
         G_Retirement_Type_Code,
         G_Asset_Type,
         G_Location_Id,
         G_Employee_Id,
         G_Category_Id,
         G_Asset_Key_Id,
         G_From_Asset_Number,
         G_To_Asset_Number,
         G_From_DPIS,
         G_To_DPIS,
         G_model_number,
         G_serial_number,
         G_tag_number,
         G_manufacturer_name,
         G_units,
         G_Attribute1,              G_Attribute2,
         G_Attribute3,              G_Attribute4,
         G_Attribute5,              G_Attribute6,
         G_Attribute7,              G_Attribute8,
         G_Attribute9,              G_Attribute10,
         G_Attribute11,             G_Attribute12,
         G_Attribute13,             G_Attribute14,
         G_Attribute15,             G_Attribute_category_code,
         G_Segment1_Low,            G_Segment2_Low,
         G_Segment3_Low,            G_Segment4_Low,
         G_Segment5_Low,            G_Segment6_Low,
         G_Segment7_Low,            G_Segment8_Low,
         G_Segment9_Low,            G_Segment10_Low,
         G_Segment11_Low,           G_Segment12_Low,
         G_Segment13_Low,           G_Segment14_Low,
         G_Segment15_Low,           G_Segment16_Low,
         G_Segment17_Low,           G_Segment18_Low,
         G_Segment19_Low,           G_Segment20_Low,
         G_Segment21_Low,           G_Segment22_Low,
         G_Segment23_Low,           G_Segment24_Low,
         G_Segment25_Low,           G_Segment26_Low,
         G_Segment27_Low,           G_Segment28_Low,
         G_Segment29_Low,           G_Segment30_Low,
         G_Segment1_High,           G_Segment2_High,
         G_Segment3_High,           G_Segment4_High,
         G_Segment5_High,           G_Segment6_High,
         G_Segment7_High,           G_Segment8_High,
         G_Segment9_High,           G_Segment10_High,
         G_Segment11_High,          G_Segment12_High,
         G_Segment13_High,          G_Segment14_High,
         G_Segment15_High,          G_Segment16_High,
         G_Segment17_High,          G_Segment18_High,
         G_Segment19_High,          G_Segment20_High,
         G_Segment21_High,          G_Segment22_High,
         G_Segment23_High,          G_Segment24_High,
         G_Segment25_High,          G_Segment26_High,
         G_Segment27_High,          G_Segment28_High,
         G_Segment29_High,          G_Segment30_High,
         G_Currency_Code,
         G_Book_Class,
         G_From_Cost,
         G_To_Cost,
         G_Fully_Rsvd_Flag,
         G_Group_Asset_Id,
         G_Group_Association;
   CLOSE mass_retirement;

   -- NULL means we don't care: -99
   -- STANDALONE means only pick up non-group associated assets: -1
   -- MEMBER means pick up only those attached to same specified group
   if(G_Group_Association is null) then
      G_Group_Asset_Id := -99;
   elsif (G_Group_Association = 'STANDALONE') then
      G_Group_Asset_Id := -1;
   end if;

   g_batch_name := 'MASSRET-' || to_char(G_mass_retirement_id);

   g_mode := p_mode;

-- it doesn't make sense to extend search if units are not entered.
   if nvl(g_units,0) > 0 then
        g_extend_search := p_extend_search;
   else
        g_extend_search := 'NO';
   end if;


   -- dump out the headings
   if g_mode = 'BATCH' then
     fnd_message.set_name('OFA', 'FA_MASSRET_INFO');
     fnd_message.set_token('ID', g_mass_retirement_id, FALSE);
     l_msg_data := substrb(fnd_message.get, 1, 100);

     FND_FILE.put(FND_FILE.output,l_msg_data);
     FND_FILE.new_line(FND_FILE.output,1);


     fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_COLUMN');
     l_string := fnd_message.get;

     FND_FILE.put(FND_FILE.output,l_string);
     FND_FILE.new_line(FND_FILE.output,1);

     fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_LINE');
     l_string := fnd_message.get;

     FND_FILE.put(FND_FILE.output,l_string);
     FND_FILE.new_line(FND_FILE.output,1);
   end if;

   if not fa_cache_pkg.fazcbc(X_book => G_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise error_found;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'g_batch_name', g_batch_name, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'g_retirement_date', g_retirement_date, p_log_level_rec => g_log_level_rec);
   end if;

--   if (G_status <> 'RUNNING_CRE') then
   if (G_status not in ('RUNNING_CRE','PENDING')) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'g_status', g_status, p_log_level_rec => g_log_level_rec);
      end if;
      fa_srvr_msg.add_message(name => 'FA_MASSRET_INVALID_STATUS',
                              calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      raise error_found;
   else -- purge any prior / incomplete data from mass ext ret
      delete from fa_mass_ext_retirements
       where batch_name = g_batch_name;
      commit;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'after deleting from mass_ext_ret', g_from_asset_number, p_log_level_rec => g_log_level_rec);
   end if;

   SELECT Precision, Extended_precision, MINIMUM_ACCOUNTABLE_UNIT
     INTO G_Precision, G_Ext_Precision, G_Min_Acct_Unit
     FROM FND_CURRENCIES
    WHERE Currency_code = G_Currency_Code;

   -- determine all canidate assets for this batch

      OPEN qual_ass_by_asset_number;

   loop

      FETCH qual_ass_by_asset_number BULK COLLECT
         INTO l_Asset_Id,
               l_asset_number,
               l_Cost_Retired,
               l_current_units
         LIMIT l_batch_size;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'After bulk fetch','' , p_log_level_rec => g_log_level_rec);
      end if;


      if (l_asset_id.count = 0) then
          exit;
      end if;


      for l_loop_count in 1..l_asset_id.count loop

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'In main asset loop',l_asset_id(l_loop_count) );
        end if;


         IF G_Retire_Subcomponents = 'YES' THEN

            OPEN subcomponents (p_parent_asset_id => l_asset_id(l_loop_count));
            FETCH subcomponents BULK COLLECT
             INTO l_SC_Asset_Id,
                  l_SC_Asset_Number,
                  l_parent_asset_id,
                  l_sc_units;
            CLOSE subcomponents;

            for l_loop_count_sub in 1..l_SC_Asset_Id.count loop


               IF l_SC_Asset_Id(l_loop_count_sub) = l_Asset_Id(l_loop_count) then

                  l_SC_Cost_Retired := l_Cost_Retired(l_loop_count);
               ELSE -- l_SC_Asset_Id ...

                  OPEN subcomponent_detail (p_asset_id => l_SC_Asset_Id(l_loop_count_sub));
                  FETCH subcomponent_detail
                   INTO l_SC_Cost_Retired;

                  IF subcomponent_detail%NOTFOUND THEN
                     l_Subcomponent_Excluded := 'Y';
                  ELSE
                     l_Subcomponent_Excluded := 'N';
                  END IF; -- subcomponent_detail%NOTFOUND

                  CLOSE subcomponent_detail;

               END IF; -- l_SC_Asset_Id ...


               If l_parent_asset_id is not null then
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(  l_calling_fn,
                                        'Subcomponent asset exist ',
                                        l_sc_asset_id(l_loop_count_sub) );
                  end if;
----
--  RN Assets in taxbook cannot be partially unit retired.
                If G_Book_Class = 'TAX' then
                        Check_Tax_Split(l_sc_Asset_Id(l_loop_count_sub),
                                        l_Emp_Split,
                                        l_Acct_Split,
                                        l_Loc_Split);

                        l_Null_Segment_Flag := Check_Account_Null;
                        if (g_log_level_rec.statement_level) then
                            fa_debug_pkg.add(l_calling_fn,
                                             'After check_tax_split - subcomp',
                                             l_sc_asset_id(l_loop_count_sub));
                            fa_debug_pkg.add(l_calling_fn,
                                             'After check_tax_split - subcomp',
                                             l_loc_split, p_log_level_rec => g_log_level_rec);
                        end if;
                End if;

                IF (Check_Addition_Retirement(l_sc_Asset_Id(l_loop_count_sub), l_Reason_Code)) THEN
                        l_failure_count := l_failure_count + 1;
                        Write_Message(l_sc_Asset_Number(l_loop_count_sub),
                                   l_reason_code,'','');
                ELSIF (Check_Extended_Life
                        (l_sc_Asset_Id(l_loop_count_sub))) then

                        l_failure_count := l_failure_count + 1;
                        Write_Message(l_sc_Asset_Number(l_loop_count_sub),
                                   'FA_MASSRET_EXTENDED_LIFE','','');
                ELSIF (G_Employee_Id IS NOT NULL AND
                        l_Emp_Split = 'Y' AND
                        G_Book_Class = 'TAX') THEN
                        l_failure_count := l_failure_count + 1;
                        Write_Message(l_sc_Asset_Number(l_loop_count_sub),
                                   'FA_MASSRET_MULTIPLE_EMP','','');
                ELSIF (l_Null_Segment_Flag = 'N' AND
                        l_Acct_Split = 'Y' AND
                        G_Book_Class = 'TAX') THEN

                        l_failure_count := l_failure_count + 1;
                        Write_Message(l_sc_Asset_Number(l_loop_count_sub),
                                   'FA_MASSRET_MULTIPLE_GL','','');
                 ELSIF (G_Location_Id IS NOT NULL AND
                        l_Loc_Split = 'Y' AND
                        G_Book_Class = 'TAX') THEN

                        l_failure_count := l_failure_count + 1;
                        Write_Message(l_sc_Asset_Number(l_loop_count_sub),
                                   'FA_MASSRET_MULTIPLE_LOC','','');

--
                ELSIF l_Subcomponent_Excluded = 'Y' THEN
                        l_failure_count := l_failure_count + 1;
                        Write_Message(l_sc_Asset_Number(l_loop_count_sub),
                                   'FA_MASSRET_EXTENDED_LIFE','','');


                  ELSE
                        if (g_log_level_rec.statement_level) then
                            fa_debug_pkg.add(l_calling_fn,
                                             'Else 1 - subcomp',
                                             '', p_log_level_rec => g_log_level_rec);
                        end if;
                     l_candidate_asset_id(l_candidate_asset_id.count + 1) := l_SC_Asset_Id(l_loop_count_sub);


                        if (g_log_level_rec.statement_level) then
                            fa_debug_pkg.add(l_calling_fn,
                                             'Else 1 - subcomp l_sc_cost_retired',
                                             l_sc_cost_retired, p_log_level_rec => g_log_level_rec);

                            fa_debug_pkg.add(l_calling_fn,
                                             'Else 1 - subcomp l_cost_retired',
                                             l_cost_retired(l_loop_count) );

                            fa_debug_pkg.add(l_calling_fn,
                                             'Else 1 - subcomp l_total_cost_retired',
                                             l_total_cost_retired , p_log_level_rec => g_log_level_rec);
                            fa_debug_pkg.add(l_calling_fn,
                                             'Else 1 - subcomp l_to l_sc_units ',
                                                 l_sc_units(l_loop_count_sub) );

                        end if;
                     l_candidate_cost_retired(l_candidate_cost_retired.count + 1) := l_sc_cost_retired;

                     l_Total_Count_Retired := l_Total_Count_Retired + 1;

                     l_total_cost_retired := l_total_cost_retired + l_cost_retired(l_loop_count);

                     l_candidate_units(l_candidate_units.count + 1) := l_sc_units(l_loop_count_sub);

                        if (g_log_level_rec.statement_level) then

                            fa_debug_pkg.add(l_calling_fn,
                                             'Else 1 - subcomp l_total_cost_retired',
                                             l_total_cost_retired , p_log_level_rec => g_log_level_rec);


                        end if;
-- rn Print message during allocate_units when there are units to prorate,
--    because some of these assets may be deleted from fa_mass_ext_retirements
--    due to unit buckets are emptied.
                     If  nvl(G_UNITS,0)  = 0 then
                        Write_Message(l_sc_Asset_Number(l_loop_count_sub),'FA_SHARED_INSERT_DEBUG','','');
                     End if;
                  END IF;

               End if;

            END LOOP; -- subcomponents

         END IF; -- l_Retire_Subcomponents ...
         if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'End subcomponent loop','' , p_log_level_rec => g_log_level_rec);
         end if;

--
-- RN Assets in taxbook cannot be partially unit retired.
         If G_Book_Class = 'TAX' then
              Check_Tax_Split(  l_Asset_Id(l_loop_count),
                                l_Emp_Split,
                                l_Acct_Split,
                                l_Loc_Split);

                l_Null_Segment_Flag := Check_Account_Null;
                if (g_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn,
                                     'After check_tax_split ',
                                     l_asset_id(l_loop_count));
                    fa_debug_pkg.add(l_calling_fn,
                                     'After check_tax_split ',
                                     l_loc_split, p_log_level_rec => g_log_level_rec);
                end if;
         End if;

         IF (Check_Addition_Retirement(l_Asset_Id(l_loop_count), l_Reason_Code)) THEN
              l_failure_count := l_failure_count + 1;
              Write_Message(l_Asset_Number(l_loop_count),
                                   l_reason_code,'','');
         ELSIF (Check_Extended_Life
                        (l_Asset_Id(l_loop_count))) then
              l_failure_count := l_failure_count + 1;
              Write_Message(l_Asset_Number(l_loop_count),
                                   'FA_MASSRET_EXTENDED_LIFE','','');
         ELSIF (G_Employee_Id IS NOT NULL AND
                        l_Emp_Split = 'Y' AND
                        G_Book_Class = 'TAX') THEN
              l_failure_count := l_failure_count + 1;
              Write_Message(l_Asset_Number(l_loop_count),
                                   'FA_MASSRET_MULTIPLE_EMP','','');
         ELSIF (l_Null_Segment_Flag = 'N' AND
                        l_Acct_Split = 'Y' AND
                        G_Book_Class = 'TAX') THEN

              l_failure_count := l_failure_count + 1;
              Write_Message(l_Asset_Number(l_loop_count),
                                   'FA_MASSRET_MULTIPLE_GL','','');
         ELSIF (G_Location_Id IS NOT NULL AND
                        l_Loc_Split = 'Y' AND
                        G_Book_Class = 'TAX') THEN
              l_failure_count := l_failure_count + 1;
              Write_Message(l_Asset_Number(l_loop_count),
                                   'FA_MASSRET_MULTIPLE_LOC','','');
--
         ELSE
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'Not subcomponent branch',
                                l_asset_id(l_loop_count) );
            end if;

            l_candidate_asset_id(l_candidate_asset_id.count + 1) := l_Asset_Id(l_loop_count);
            l_candidate_cost_retired(l_candidate_cost_retired.count + 1) := l_cost_retired(l_loop_count);
            l_Total_Count_Retired := l_Total_Count_Retired + 1;
            l_total_cost_retired := l_total_cost_retired + l_cost_retired(l_loop_count);
            l_candidate_units(l_candidate_units.count + 1) := l_current_units(l_loop_count);
            If  nvl(G_UNITS,0)  = 0 then
                Write_Message(l_Asset_Number(l_loop_count),'FA_SHARED_INSERT_DEBUG','','');
            End if;
         END IF;

      END LOOP; -- qualified_assets


      For l_count in 1..l_candidate_asset_id.count loop

         /*Bug 8647381 - Start*/
         l_recognize_gain_loss := null;

         OPEN c_recognize_gain_loss(l_candidate_asset_id(l_count));
         FETCH c_recognize_gain_loss
          INTO l_recognize_gain_loss;
         CLOSE c_recognize_gain_loss;
         /*Bug 8647381 - End*/

        if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Starting candidate loop', l_count , p_log_level_rec => g_log_level_rec);
        end if;

        l_Null_Segment_Flag := Check_Account_Null;

        if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'check_account_null', l_null_segment_flag  , p_log_level_rec => g_log_level_rec);
        end if;

        if (g_location_id is not null or
           g_employee_id is not null or
           l_null_segment_flag = 'N') then


           if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Before check_split call',
                        l_count, p_log_level_rec => g_log_level_rec);
           end if;

           if not Check_Split_Distribution(l_candidate_Asset_Id(l_count),
                   l_asset_dist_tbl
                   )  then
                raise error_found;
           end if;

        end if;


-- g_book_class = TAX condition implemented due to bug 3749651

        if l_asset_dist_tbl.count = 0  OR G_Book_Class = 'TAX' then


            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'After check_split dist.', ''  , p_log_level_rec => g_log_level_rec);
            end if;
-- bug 3749651
            l_asset_dist_tbl.delete;

            l_asset_dist_tbl(1).expense_ccid := '';
            l_asset_dist_tbl(1).location_ccid := '';
            l_asset_dist_tbl(1).assigned_to := '';
-- bug 3749651
            if ( nvl(g_units,0) > 0) and (G_Book_Class <> 'TAX') then
              l_asset_dist_tbl(1).units_assigned := l_candidate_units(l_count);
            else
              l_asset_dist_tbl(1).units_assigned := '';
            end if;
        end if;


--

        l_total_dist_cost := l_candidate_cost_retired(l_count);



        For l_dist_count in 1..l_asset_dist_tbl.count loop

         if l_asset_dist_tbl(l_dist_count).expense_ccid is not null then

              l_candidate_cost_retired(l_count) :=
                round( (l_asset_dist_tbl(l_dist_count).units_assigned /
                        l_candidate_units(l_count)) *
                        l_total_dist_cost, g_precision);

         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                        'Before insert into fa_mass_ext_ret ccid',
                        l_asset_dist_tbl(l_dist_count).expense_ccid   );
         end if;

         insert into fa_mass_ext_retirements
             (batch_name,
              mass_external_retire_id,
              book_type_code,
              review_status,
              asset_id,
              calc_gain_loss_flag,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              cost_retired,
              cost_of_removal,
              proceeds_of_sale,
              retirement_type_code,
              date_retired,
              transaction_name,
              units,
              code_combination_id,
              location_id,
              assigned_to,
	      attribute_category,   --bug#7287382
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
	      th_attribute_category, --bug#7287382
              th_attribute1,
              th_attribute2,
              th_attribute3,
              th_attribute4,
              th_attribute5,
              th_attribute6,
              th_attribute7,
              th_attribute8,
              th_attribute9,
              th_attribute10,
              th_attribute11,
              th_attribute12,
              th_attribute13,
              th_attribute14,
              th_attribute15,
              recognize_gain_loss
              )
         values
             (g_batch_name,
              fa_mass_ext_retirements_s.nextval,
              G_book_type_code,
              decode(nvl(g_units,0),'0','POST','DELETE'),
              l_candidate_asset_id(l_count),
              'NO',
              g_last_updated_by,
              sysdate,
              g_last_updated_by,
              sysdate,
              g_last_update_login,
              l_candidate_cost_retired(l_count),
              0,
              0,
              G_retirement_type_code,
              G_retirement_date,
              G_transaction_name,
              l_asset_dist_tbl(l_dist_count).units_assigned,
              l_asset_dist_tbl(l_dist_count).expense_ccid,
              l_asset_dist_tbl(l_dist_count).location_ccid,
              l_asset_dist_tbl(l_dist_count).assigned_to,
	      g_attribute_category_code,    --bug#7287382
              g_attribute1,
              g_attribute2,
              g_attribute3,
              g_attribute4,
              g_attribute5,
              g_attribute6,
              g_attribute7,
              g_attribute8,
              g_attribute9,
              g_attribute10,
              g_attribute11,
              g_attribute12,
              g_attribute13,
              g_attribute14,
              g_attribute15,
	      g_attribute_category_code,    --bug#7287382
              g_attribute1,
              g_attribute2,
              g_attribute3,
              g_attribute4,
              g_attribute5,
              g_attribute6,
              g_attribute7,
              g_attribute8,
              g_attribute9,
              g_attribute10,
              g_attribute11,
              g_attribute12,
              g_attribute13,
              g_attribute14,
              g_attribute15,
              l_recognize_gain_loss
                );

              if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                        'After insert into FA_MASS_EXT_RETIREMENTS table, asset_id',
              l_candidate_asset_id(l_count));
                fa_debug_pkg.add(l_calling_fn,
                        'After insert into FA_MASS_EXT_RETIREMENTS table, units_assigned',
                        l_asset_dist_tbl(l_dist_count).units_assigned );
                fa_debug_pkg.add(l_calling_fn,
                        'After insert into FA_MASS_EXT_RETIREMENTS table, cost_retired',
                              l_candidate_cost_retired(l_count));

                fa_debug_pkg.add(l_calling_fn,
                        'After insert into FA_MASS_EXT_RETIREMENTS table',
                        l_candidate_units(l_count) );

              end if;

            end loop;

           if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'After dh-insert loop', ''  , p_log_level_rec => g_log_level_rec);
           end if;
           l_asset_dist_tbl.delete;
           end loop;

           if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'After candidate loop', ''  , p_log_level_rec => g_log_level_rec);
           end if;


      l_asset_id.delete;
      l_asset_number.delete;
      l_cost_retired.delete;
      l_SC_Asset_Id.delete;
      l_SC_Asset_Number.delete;
      l_parent_asset_id.delete;
      l_candidate_asset_id.delete;
      l_candidate_cost_retired.delete;
-- bug5324491
      l_candidate_units.delete;


   end loop; -- bulk fetch

   CLOSE qual_ass_by_asset_number;

-- Allocating units section
   If  nvl(G_UNITS,0)  > 0 and g_book_class <> 'TAX' then
       if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Calling unit allocation',g_units , p_log_level_rec => g_log_level_rec);
      end if;

-- return success_count and failure_count

      if not allocate_units(suxess_no, fail_no) then
         raise error_found;
      end if;


      l_total_count_retired := suxess_no;
      if fail_no > 0 then

        l_failure_count := fail_no;
      end if;


   end if;  -- g_units > 0


   -- now that we've determined the total cost, refetch all assets and then
   -- calculate and update the COR and POS amounts accordingly

   select count(*),
          sum(abs(cost_retired))
     into l_total_count_retired,
          l_total_cost_retired
     from fa_mass_ext_retirements
    where batch_name = g_batch_name;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'G_proceeds_of_sale',
                       G_proceeds_of_sale, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'G_cost_of_removal',
                       G_cost_of_removal, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'l_total_cost_retired',
                       l_total_cost_retired, p_log_level_rec => g_log_level_rec);
   end if;

   IF (((G_Cost_Of_Removal = 0) AND (G_Proceeds_Of_Sale=0)) OR
       (l_Total_Cost_Retired = 0)) THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'not allocating any POS / COR amounts',
                          '', p_log_level_rec => g_log_level_rec);
      end if;
   ELSE

      OPEN mass_ret_assets(g_batch_name);

      loop

         FETCH mass_ret_assets BULK COLLECT
          INTO l_Asset_Id,
               l_Cost_Retired
         LIMIT l_batch_size;

         select count(*)
           into l_msg_count
           from fa_mass_ext_retirements
          where batch_name = g_batch_name;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'count of records in mass_ext_ret',
                          l_msg_count, p_log_level_rec => g_log_level_rec);
      end if;

         if (l_asset_id.count = 0) then
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'no assets found in the cursor',
                                'mass_ret_assets', p_log_level_rec => g_log_level_rec);
            end if;
            exit;
            --raise done_exc;
         end if;

         for l_loop_count in 1..l_asset_id.count loop

            l_Running_Asset_Count := l_Running_Asset_Count + 1;

            IF l_Running_Asset_Count = (l_Total_Count_Retired) THEN

               l_Prorated_Cost_Of_Removal(l_loop_count)  := G_Cost_Of_Removal -
                                                            l_Running_Prorated_Cost;
               l_Prorated_Proceeds_Of_Sale(l_loop_count) := G_Proceeds_Of_Sale -
                                                            l_Running_Prorated_POS;
            ELSE

               l_Prorated_Cost_Of_Removal(l_loop_count)  := TRUNC(( abs(l_Cost_Retired(l_loop_count) )* G_Cost_Of_Removal)
                                                             /l_total_cost_retired, G_Precision);
               l_Prorated_Proceeds_Of_Sale(l_loop_count) := TRUNC(( abs(l_Cost_Retired(l_loop_count) ) * G_Proceeds_Of_Sale)
                                                             /l_total_cost_retired, G_Precision);
            END IF;

            l_Running_Prorated_POS   := l_Running_Prorated_POS +
                                        l_Prorated_Proceeds_Of_Sale(l_loop_count);
            l_Running_Prorated_Cost  := l_Running_Prorated_Cost +
                                        l_Prorated_Cost_Of_Removal(l_loop_count);
            l_Running_Count_Retired  := l_Running_Count_Retired + 1;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                       'l_Cost_Retired',
                        l_Cost_Retired(l_loop_count));
               fa_debug_pkg.add(l_calling_fn,
                       'l_Running_Prorated_POS',
                        l_Running_Prorated_POS, p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn,
                       'l_Prorated_Proceeds_Of_Sale',
                        l_Prorated_Proceeds_Of_Sale(l_loop_count));
               fa_debug_pkg.add(l_calling_fn,
                       'l_Running_Prorated_Cost',
                        l_Running_Prorated_Cost, p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn,
                       'l_Prorated_Cost_Of_Removal',
                        l_Prorated_Cost_Of_Removal(l_loop_count));
               fa_debug_pkg.add(l_calling_fn,
                       'l_Running_Count_Retired',
                        l_Running_Count_Retired, p_log_level_rec => g_log_level_rec);
            end if;
         END LOOP;

         FORALL l_count in 1..l_asset_id.count
         UPDATE fa_mass_ext_retirements
            SET cost_of_removal    = l_prorated_cost_of_removal(l_count),
                proceeds_of_sale   = l_prorated_proceeds_of_sale(l_count)
          where asset_id           = l_asset_id(l_count)
            and batch_name         = g_batch_name;

         l_asset_id.delete;
         l_cost_retired.delete;
         l_prorated_cost_of_removal.delete;
         l_prorated_proceeds_of_sale.delete;

      END LOOP; -- end bulk loop

      CLOSE mass_ret_assets;

   END IF; -- COR or POS

   -- Dump the totals to the log
   --   X_Total_Cost_Retired  := G_Total_Cost_Retired;
   --   X_Total_Count_Retired := G_Total_Count_Retired;

   -- update the status so we can post the batch
   if nvl(g_units,0) = 0 then  -- status already inserted in allocate_units.
     update fa_mass_retirements
        set status = 'CREATED_RET'
      where mass_retirement_id = G_Mass_Retirement_ID;
   end if;

   commit;

   -- dump to log
--  Added if to clarify for famrpend
   if p_mode = 'BATCH' then
        fa_srvr_msg.add_message(name =>'FA_MASSRET_INFO',
                           calling_fn => NULL,
                           token1 => 'ID',
                           value1 => G_MASS_RETIREMENT_ID, p_log_level_rec => g_log_level_rec);
        FND_FILE.new_line(FND_FILE.log,2);
   end if;
   fa_srvr_msg.add_message(name =>'FA_SHARED_NUMBER_SUCCESS',
                           calling_fn => NULL,
                           token1 => 'NUMBER',
                           value1 => l_total_count_retired, p_log_level_rec => g_log_level_rec);
   fa_srvr_msg.add_message(name =>'FA_SHARED_NUMBER_FAIL',
                           calling_fn => NULL,
                           token1 => 'NUMBER',
                           value1 => l_failure_count, p_log_level_rec => g_log_level_rec);

   -- dump to execution report
   FND_FILE.new_line(FND_FILE.output,1);

   fnd_message.set_name('OFA', 'FA_SHARED_NUMBER_SUCCESS');
   fnd_message.set_token('NUMBER', to_char(l_total_count_retired), FALSE);
   l_msg_data := substrb(fnd_message.get, 1, 100);

   FND_FILE.put(FND_FILE.output,l_msg_data);
   FND_FILE.new_line(FND_FILE.output,1);


   fnd_message.set_name('OFA', 'FA_SHARED_NUMBER_FAIL');
   fnd_message.set_token('NUMBER', to_char(l_failure_count), FALSE);
   l_msg_data := substrb(fnd_message.get, 1, 100);

   FND_FILE.put(FND_FILE.output,l_msg_data);
   FND_FILE.new_line(FND_FILE.output,1);

   if g_mode = 'BATCH' then
     FND_FILE.new_line(FND_FILE.output,2);
   end if;

   -- Dump Debug messages when run in debug mode to log file
   if (l_debug) then
      FA_DEBUG_PKG.Write_Debug_Log;
   end if;

   -- write messages to log file
   FND_MSG_PUB.Count_And_Get(
        p_count                => l_msg_count,
        p_data                 => l_msg_data);
   fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);

-- Return error when not enough units.
   if nvl(g_units,0) > 0 and fail_no > 0 then
      retcode := 2;
   else
      retcode := 0;
   end if;

EXCEPTION
   WHEN done_exc then
        commit;
        retcode :=  0;
   WHEN error_found then
        rollback;
        update fa_mass_retirements
           set status = 'FAILED_CRE'
         where mass_retirement_id = G_Mass_Retirement_ID;
        commit;
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

        -- Dump Debug messages when run in debug mode to log file
        if (l_debug) then
           FA_DEBUG_PKG.Write_Debug_Log;
        end if;

        -- write messages to log file
        FND_MSG_PUB.Count_And_Get(
             p_count                => l_msg_count,
             p_data                 => l_msg_data);
        fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);

        retcode := 2;

   WHEN others THEN
        rollback;
        update fa_mass_retirements
           set status = 'FAILED_CRE'
         where mass_retirement_id = G_Mass_Retirement_ID;
        commit;
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

        -- Dump Debug messages when run in debug mode to log file
        if (l_debug) then
           FA_DEBUG_PKG.Write_Debug_Log;
        end if;

        -- write messages to log file
        FND_MSG_PUB.Count_And_Get(
             p_count                => l_msg_count,
             p_data                 => l_msg_data);
        fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);

        retcode :=  2;

END Create_Mass_Retirements;

END FA_MASS_RET_PKG;

/
