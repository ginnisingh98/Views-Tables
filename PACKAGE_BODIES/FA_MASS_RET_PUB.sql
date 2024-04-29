--------------------------------------------------------
--  DDL for Package Body FA_MASS_RET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_RET_PUB" as
/* $Header: FAPMRLDB.pls 120.7.12010000.2 2009/07/19 12:16:24 glchen ship $   */



PROCEDURE CREATE_CRITERIA
   (p_api_version           	in     NUMBER
   ,p_init_msg_list        	in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                	in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level      	in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn            	in     VARCHAR2
   ,x_return_status         	out    NOCOPY VARCHAR2
   ,x_msg_count             	out    NOCOPY NUMBER
   ,x_msg_data              	out    NOCOPY VARCHAR2
   ,px_mass_ret_rec             in out
			NOCOPY FA_CUSTOM_RET_VAL_PKG.mass_ret_rec_tbl_type) IS



  l_mass_ret_rec	fa_custom_ret_val_pkg.mass_ret_rec_tbl_type;
  mr_count		NUMBER;
  validation_error 	Exception;
  error_code		varchar2(30);

-- validation cursors

   l_found 	varchar2(30);

   l_fiscal_year_name	fa_book_controls.fiscal_year_name%TYPE;
   l_fiscal_year 	fa_deprn_periods.fiscal_year%TYPE;
   l_book_class 	fa_book_controls.book_class%TYPE;
   l_per_close_date	fa_deprn_periods.calendar_period_close_date%TYPE;
   l_book		fa_book_controls.book_type_code%TYPE;

   l_category_id	fa_categories.category_id%TYPE;
   l_retirement_type_code fa_mass_retirements.retirement_type_code%TYPE;
   l_retirement_date	date;
   l_status		fa_lookups_b.lookup_code%TYPE;
   l_location_id	fa_locations.location_id%TYPE;
   l_employee_id 	number;
   l_asset_key_id	fa_mass_retirements.asset_key_id%TYPE;
   l_from_asset_no 	fa_additions_b.asset_number%TYPE;
   l_to_asset_no	fa_additions_b.asset_number%TYPE;

   l_msg_data	        varchar2(200);
   l_loop_no		number;
   l_yesno		varchar2(10);

	  cursor c_bc is
	  select bc.fiscal_year_name,
		 bc.current_fiscal_year,
		 bc.book_class,
		 dp.calendar_period_close_date
	  from fa_book_controls bc,
		fa_deprn_periods dp
	  where bc.book_type_code = l_book
	  and   bc.last_period_counter = dp.period_counter
	  and   dp.book_type_code = bc.book_type_code
	  and   bc.book_class <> 'BUDGET'
	  and   nvl(bc.date_ineffective, sysdate + 1) > sysdate;

	  cursor c_cb is
	   Select 'Validated'
	   From fa_category_books cb
	   Where book_type_code = l_book
	   And   category_id    = l_category_id;

	   cursor c_lu is
	   Select 'Validated'
	   From fa_lookups
	   Where lookup_type = 'RETIREMENT'
	   And lookup_code = l_retirement_type_code;

	   cursor c_rd is
	   Select 'Validated'
           FROM fa_deprn_periods fadp
           WHERE fadp.book_type_code = l_book
           AND fadp.period_close_date IS NULL
           AND l_retirement_date
                     <= fadp.calendar_period_close_date;

	   cursor c_rd2 is
             SELECT 'Validated'
             FROM fa_fiscal_year
             WHERE fiscal_year      = l_fiscal_year
             AND   fiscal_year_name = l_fiscal_year_name
                   AND l_retirement_date
                       BETWEEN start_date AND end_date;

	   cursor c_status is
             SELECT 'Validated'
	     FROM FA_LOOKUPS
             WHERE LOOKUP_TYPE = 'MASS_TRX_STATUS'
             AND LOOKUP_CODE = l_status
	     AND LOOKUP_CODE in ('NEW','PENDING','ON_HOLD');


	   cursor c_loc is
             SELECT 'Validated'
	     FROM FA_LOCATIONS
             WHERE location_id = l_location_id
	     AND  sysdate between nvl(start_date_active,sysdate -1)
		 and nvl(end_date_active, sysdate +1)
	     AND  enabled_flag = 'Y';

	   cursor c_emp is
             SELECT 'Validated'
	     FROM FA_EMPLOYEES
             WHERE employee_id = l_employee_id;

	   cursor c_key is
             SELECT 'Validated'
	     FROM FA_ASSET_KEYWORDS
             WHERE code_combination_id = l_asset_key_id;

	   cursor c_fromasset is
	     Select 'Validated'
	     From fa_books bk,
		  fa_additions ad
	     Where ad.asset_number = l_from_asset_no
	     And ad.asset_id = bk.asset_id
	     And bk.book_type_code = l_book
	     And bk.date_ineffective is null;

	   cursor c_toasset is
	     Select 'Validated'
	     From fa_books bk,
		  fa_additions ad
	     Where ad.asset_number = l_to_asset_no
	     And ad.asset_id = bk.asset_id
	     And bk.book_type_code = l_book
	     And bk.date_ineffective is null;

-- end validation cursors

Begin

   l_mass_ret_rec := px_mass_ret_rec;


   FOR  mr_count in 1..l_mass_ret_rec.count LOOP

	l_loop_no := mr_count;
/* Use same validation as in Create Mass Retirements form */

	l_book := l_mass_ret_rec(mr_count).book_type_code;
	l_category_id := l_mass_ret_rec(mr_count).category_id;
	l_retirement_type_code := l_mass_ret_rec(mr_count).retirement_type_code;
	l_retirement_date 	:= l_mass_ret_rec(mr_count).retirement_date;
	l_status		:= l_mass_ret_rec(mr_count).status;
	l_location_id	:= l_mass_ret_rec(mr_count).location_id;
	l_employee_id 	:= l_mass_ret_rec(mr_count).employee_id;
	l_asset_key_id	:= l_mass_ret_rec(mr_count).asset_key_id;
	l_from_asset_no := l_mass_ret_rec(mr_count).from_asset_number;
	l_to_asset_no 	:= l_mass_ret_rec(mr_count).to_asset_number;

        open c_bc;
	fetch c_bc into l_fiscal_year_name,
			l_fiscal_year,
			l_book_class,
		   	l_per_close_date;

	if c_bc%NOTFOUND then
		error_code := 'BOOK_TYPE_CODE';
		raise validation_error;
	end if;
	close c_bc;

	IF l_mass_ret_rec(mr_count).category_id is not null then

	  open c_cb;
	  fetch c_cb into l_found;
	  if c_cb%NOTFOUND then
		error_code := 'CATEGORY';
		raise validation_error;
	  end if;
	  close c_cb;
	End if;

	If l_mass_ret_rec(mr_count).retirement_type_code is not null then
	  open c_lu;
	  fetch c_lu into l_found;
	  if c_lu%NOTFOUND then
		error_code := 'RETIREMENT_TYPE_CODE';
		raise validation_error;
	  end if;
	  close c_lu;
	End if;

	If l_mass_ret_rec(mr_count).retirement_date is not null then

	  open c_rd;
	  fetch c_rd into l_found;
	  if c_rd%NOTFOUND then
		error_code := 'RETIREMENT_DATE';
		raise validation_error;
	  end if;
	  close c_rd;

	  open c_rd2;
	  fetch c_rd2 into l_found;
	  if c_rd2%NOTFOUND then
		error_code := 'RETIREMENT_DATE2';
		raise validation_error;
	  end if;
	  close c_rd2;
	End if;

	If l_mass_ret_rec(mr_count).status is not null then
	  open c_status;
	  fetch c_status into l_found;
	  if c_status%NOTFOUND then
		error_code := 'STATUS';
		raise validation_error;
	  end if;
	  close c_status;
	End if;

	If (nvl(l_mass_ret_rec(mr_count).units_to_retire,0) > 0)
	and l_book_class = 'TAX' then
		error_code := 'TAX';
		raise validation_error;
	end if;

	If nvl(l_mass_ret_rec(mr_count).units_to_retire,0) < 0 then
		error_code := 'UNITS';
		raise validation_error;
	end if;

	if nvl(l_mass_ret_rec(mr_count).retire_subcomponents_flag,'NO')
	not in  ('NO','YES') then
	   	l_yesno := l_mass_ret_rec(mr_count).retire_subcomponents_flag;
		error_code := 'SUBCOMPONENTS';
		raise validation_error;
	end if;

-- PROJECT AND TASK VALIDATION

-- End project and task

	if nvl(l_mass_ret_rec(mr_count).asset_type,'CIP') not in ('EXPENSED',
		'CAPITALIZED','CIP') then
		error_code := 'ASSET TYPE';
		raise validation_error;
	end if;

	if nvl(l_mass_ret_rec(mr_count).INCLUDE_FULLY_RSVD_FLAG,'NO')
	not in ('YES','NO') then
		error_code := 'FULLY_RSVD';
		raise validation_error;
	end if;

	if l_mass_ret_rec(mr_count).location_id is not null then

	  open c_loc;
	  fetch c_loc into l_found;
	  if c_loc%NOTFOUND then
		error_code := 'LOCATION';
		raise validation_error;
	  end if;
	  close c_loc;

	end if;

	if l_mass_ret_rec(mr_count).employee_id is not null then

	  open c_emp;
	  fetch c_emp into l_found;
	  if c_emp%NOTFOUND then
		error_code := 'EMPLOYEE';
		raise validation_error;
	  end if;
	  close c_emp;

	end if;

	if l_mass_ret_rec(mr_count).asset_key_id is not null then

	  open c_key;
	  fetch c_key into l_found;
	  if c_key%NOTFOUND then
		error_code := 'KEY';
		raise validation_error;
	  end if;
	  close c_key;

	end if;

	if l_mass_ret_rec(mr_count).from_cost is not null then

	  if l_mass_ret_rec(mr_count).from_cost >
		nvl(l_mass_ret_rec(mr_count).to_cost,0) then
		error_code := 'COST';
		raise validation_error;

	  end if;

	end if;

	if l_mass_ret_rec(mr_count).from_asset_number is not null then
	  if l_mass_ret_rec(mr_count).from_asset_number <=
			l_mass_ret_rec(mr_count).to_asset_number then

	     open c_fromasset;
	     fetch c_fromasset into l_found;
	     if c_fromasset%NOTFOUND then
		error_code := 'FROM ASSET';
		raise validation_error;
	     end if;
	     close c_fromasset;

	     open c_toasset;
	     fetch c_toasset into l_found;
	     if c_toasset%NOTFOUND then
		error_code := 'TO ASSET';
		raise validation_error;
	     end if;
	     close c_toasset;

	  else
		error_code := 'FROM ASSET';
		raise validation_error;

	  end if;


	end if;

	if l_mass_ret_rec(mr_count).from_date_placed_in_service is not null then


           if (l_mass_ret_rec(mr_count).from_date_placed_in_service > l_per_close_date)
	   or
	      (l_mass_ret_rec(mr_count).to_date_placed_in_service > l_per_close_date)
	   then
		error_code := 'DPIS';
		raise validation_error;
	   end if;
	end if;


     Insert into fa_mass_retirements (
	MASS_RETIREMENT_ID,
	BOOK_TYPE_CODE,
	RETIRE_SUBCOMPONENTS_FLAG,
	STATUS,
	RETIRE_REQUEST_ID,
	REINSTATE_REQUEST_ID,
	RETIREMENT_DATE,
	PROCEEDS_OF_SALE,
	COST_OF_REMOVAL,
	DESCRIPTION,
	RETIREMENT_TYPE_CODE,
	ASSET_TYPE,
	LOCATION_ID,
	EMPLOYEE_ID,
	CATEGORY_ID,
	ASSET_KEY_ID,
	FROM_ASSET_NUMBER,
	TO_ASSET_NUMBER,
	FROM_DATE_PLACED_IN_SERVICE,
	TO_DATE_PLACED_IN_SERVICE,
	FROM_COST,
	MODEL_NUMBER,
	TAG_NUMBER,
	MANUFACTURER_NAME,
	SERIAL_NUMBER,
	CREATE_REQUEST_ID,
	UNITS_TO_RETIRE,
	INCLUDE_FULLY_RSVD_FLAG,
	TO_COST,
	GROUP_ASSET_ID,
	FROM_THRESHOLD_AMOUNT,
	TO_THRESHOLD_AMOUNT,
	PROJECT_ID,
	TASK_ID,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	ATTRIBUTE_CATEGORY_CODE,
	SEGMENT1_LOW,
	SEGMENT2_LOW,
	SEGMENT3_LOW,
	SEGMENT4_LOW,
	SEGMENT5_LOW,
	SEGMENT6_LOW,
	SEGMENT7_LOW,
	SEGMENT8_LOW,
	SEGMENT9_LOW,
	SEGMENT10_LOW,
	SEGMENT11_LOW,
	SEGMENT12_LOW,
	SEGMENT13_LOW,
	SEGMENT14_LOW,
	SEGMENT15_LOW,
	SEGMENT16_LOW,
	SEGMENT17_LOW,
	SEGMENT18_LOW,
	SEGMENT19_LOW,
	SEGMENT20_LOW,
	SEGMENT21_LOW,
	SEGMENT22_LOW,
	SEGMENT23_LOW,
	SEGMENT24_LOW,
	SEGMENT25_LOW,
	SEGMENT26_LOW,
	SEGMENT27_LOW,
	SEGMENT28_LOW,
	SEGMENT29_LOW,
	SEGMENT30_LOW,
	SEGMENT1_HIGH,
	SEGMENT2_HIGH,
	SEGMENT3_HIGH,
	SEGMENT4_HIGH,
	SEGMENT5_HIGH,
	SEGMENT6_HIGH,
	SEGMENT7_HIGH,
	SEGMENT8_HIGH,
	SEGMENT9_HIGH,
	SEGMENT10_HIGH,
	SEGMENT11_HIGH,
	SEGMENT12_HIGH,
	SEGMENT13_HIGH,
	SEGMENT14_HIGH,
	SEGMENT15_HIGH,
	SEGMENT16_HIGH,
	SEGMENT17_HIGH,
	SEGMENT18_HIGH,
	SEGMENT19_HIGH,
	SEGMENT20_HIGH,
	SEGMENT21_HIGH,
	SEGMENT22_HIGH,
	SEGMENT23_HIGH,
	SEGMENT24_HIGH,
	SEGMENT25_HIGH,
	SEGMENT26_HIGH,
	SEGMENT27_HIGH,
	SEGMENT28_HIGH,
	SEGMENT29_HIGH,
	SEGMENT30_HIGH,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	FA_MASS_TRANSACTIONS_S.NEXTVAL,
	L_MASS_RET_REC(mr_count).BOOK_TYPE_CODE,
	L_MASS_RET_REC(mr_count).RETIRE_SUBCOMPONENTS_FLAG,
	L_MASS_RET_REC(mr_count).STATUS,
	L_MASS_RET_REC(mr_count).RETIRE_REQUEST_ID,
	L_MASS_RET_REC(mr_count).REINSTATE_REQUEST_ID,
	L_MASS_RET_REC(mr_count).RETIREMENT_DATE,
	L_MASS_RET_REC(mr_count).PROCEEDS_OF_SALE,
	L_MASS_RET_REC(mr_count).COST_OF_REMOVAL,
	L_MASS_RET_REC(mr_count).DESCRIPTION,
	L_MASS_RET_REC(mr_count).RETIREMENT_TYPE_CODE,
	L_MASS_RET_REC(mr_count).ASSET_TYPE,
	L_MASS_RET_REC(mr_count).LOCATION_ID,
	L_MASS_RET_REC(mr_count).EMPLOYEE_ID,
	L_MASS_RET_REC(mr_count).CATEGORY_ID,
	L_MASS_RET_REC(mr_count).ASSET_KEY_ID,
	L_MASS_RET_REC(mr_count).FROM_ASSET_NUMBER,
	L_MASS_RET_REC(mr_count).TO_ASSET_NUMBER,
	L_MASS_RET_REC(mr_count).FROM_DATE_PLACED_IN_SERVICE,
	L_MASS_RET_REC(mr_count).TO_DATE_PLACED_IN_SERVICE,
	L_MASS_RET_REC(mr_count).FROM_COST,
	L_MASS_RET_REC(mr_count).MODEL_NUMBER,
	L_MASS_RET_REC(mr_count).TAG_NUMBER,
	L_MASS_RET_REC(mr_count).MANUFACTURER_NAME,
	L_MASS_RET_REC(mr_count).SERIAL_NUMBER,
	L_MASS_RET_REC(mr_count).CREATE_REQUEST_ID,
	L_MASS_RET_REC(mr_count).UNITS_TO_RETIRE,
	L_MASS_RET_REC(mr_count).INCLUDE_FULLY_RSVD_FLAG,
	L_MASS_RET_REC(mr_count).TO_COST,
	L_MASS_RET_REC(mr_count).GROUP_ASSET_ID,
	L_MASS_RET_REC(mr_count).FROM_THRESHOLD_AMOUNT,
	L_MASS_RET_REC(mr_count).TO_THRESHOLD_AMOUNT,
	L_MASS_RET_REC(mr_count).PROJECT_ID,
	L_MASS_RET_REC(mr_count).TASK_ID,
	L_MASS_RET_REC(mr_count).ATTRIBUTE1,
	L_MASS_RET_REC(mr_count).ATTRIBUTE2,
	L_MASS_RET_REC(mr_count).ATTRIBUTE3,
	L_MASS_RET_REC(mr_count).ATTRIBUTE4,
	L_MASS_RET_REC(mr_count).ATTRIBUTE5,
	L_MASS_RET_REC(mr_count).ATTRIBUTE6,
	L_MASS_RET_REC(mr_count).ATTRIBUTE7,
	L_MASS_RET_REC(mr_count).ATTRIBUTE8,
	L_MASS_RET_REC(mr_count).ATTRIBUTE9,
	L_MASS_RET_REC(mr_count).ATTRIBUTE10,
	L_MASS_RET_REC(mr_count).ATTRIBUTE11,
	L_MASS_RET_REC(mr_count).ATTRIBUTE12,
	L_MASS_RET_REC(mr_count).ATTRIBUTE13,
	L_MASS_RET_REC(mr_count).ATTRIBUTE14,
	L_MASS_RET_REC(mr_count).ATTRIBUTE15,
	L_MASS_RET_REC(mr_count).ATTRIBUTE_CATEGORY_CODE,
	L_MASS_RET_REC(mr_count).SEGMENT1_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT2_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT3_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT4_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT5_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT6_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT7_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT8_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT9_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT10_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT11_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT12_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT13_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT14_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT15_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT16_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT17_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT18_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT19_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT20_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT21_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT22_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT23_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT24_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT25_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT26_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT27_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT28_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT29_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT30_LOW,
	L_MASS_RET_REC(mr_count).SEGMENT1_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT2_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT3_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT4_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT5_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT6_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT7_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT8_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT9_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT10_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT11_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT12_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT13_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT14_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT15_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT16_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT17_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT18_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT19_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT20_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT21_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT22_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT23_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT24_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT25_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT26_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT27_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT28_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT29_HIGH,
	L_MASS_RET_REC(mr_count).SEGMENT30_HIGH,
	L_MASS_RET_REC(mr_count).LAST_UPDATE_DATE,
	L_MASS_RET_REC(mr_count).LAST_UPDATED_BY,
	L_MASS_RET_REC(mr_count).CREATION_DATE,
	L_MASS_RET_REC(mr_count).CREATED_BY,
	L_MASS_RET_REC(mr_count).LAST_UPDATE_LOGIN
	);

  END LOOP;


	IF FND_API.To_Boolean(p_commit) THEN
                COMMIT WORK;
	END IF;

  x_return_status := 0;

  Exception
    When validation_error then

	if error_code =  'BOOK_TYPE_CODE' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_BOOK_INEFFECTIVE_BOOK');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'CATEGORY' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_BOOK_CATBOOK_NOT_DEFINED');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'RETIREMENT_TYPE_CODE' then
 	  x_msg_data := 'Retirement Type is incorrect';
--
	elsif error_code = 'RETIREMENT_DATE' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_SHARED_CANNOT_FUTURE');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'RETIREMENT_DATE2' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_RET_DATE_MUSTBE_IN_CUR_FY');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'STATUS' 	then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_SHARED_UNKNOWN_STATUS');
	  FND_MESSAGE.SET_TOKEN('STATUS',l_status, false);
	  x_msg_data := fnd_message.get;

	elsif error_code = 'TAX' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_RET_COST_ONLY');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'UNITS' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_UNT_ADJ_VAL_CUR_UNTS');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'SUBCOMPONENTS' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_API_SHARED_INVALID_YESNO');
	  FND_MESSAGE.SET_TOKEN('VALUE', l_yesno, false);
	  FND_MESSAGE.SET_TOKEN('XMLTAG', 'SUBCOMPONENTS', false);
	  x_msg_data := fnd_message.get;

	elsif error_code = 'ASSET TYPE' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_DPR_BAD_ASSET_TYPE');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'FULLY_RSVD' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_API_SHARED_INVALID_YESNO');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'LOCATION' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_INCORRECT_LOCATION');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'EMPLOYEE' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_INCORRECT_ASSIGNED_TO');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'KEY' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_INCORRECT_ASSET_KEY');
	  FND_MESSAGE.SET_TOKEN('ASSET_KEY_CCID', l_asset_key_id, false);
	  x_msg_data := fnd_message.get;

	elsif error_code = 'COST' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_FE_CANT_CALC_COST_RET');
	  x_msg_data := fnd_message.get;

	elsif error_code = 'FROM ASSET' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_REV_FAILED');
	  FND_MESSAGE.SET_TOKEN('ASSET_NUMBER',
			l_from_asset_no , false);
	  x_msg_data := fnd_message.get;

	elsif error_code = 'TO ASSET' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_REV_FAILED');
	  FND_MESSAGE.SET_TOKEN('ASSET_NUMBER',
			l_to_asset_no, false);
	  x_msg_data := fnd_message.get;

	elsif error_code = 'DPIS' then
	  FND_MESSAGE.SET_NAME('OFA', 'FA_SHARED_CANNOT_FUTURE');
	  x_msg_data := fnd_message.get;
	end if;

	x_return_status := 2;
        Rollback;
    When others then
        x_msg_data := sqlerrm;
	x_return_status := 2;
        Rollback;

END CREATE_CRITERIA;
END FA_MASS_RET_PUB;

/
