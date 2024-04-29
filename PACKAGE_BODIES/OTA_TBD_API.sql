--------------------------------------------------------
--  DDL for Package Body OTA_TBD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TBD_API" as
/* $Header: ottbd01t.pkb 120.1 2006/05/08 02:52:13 niarora noship $ */
--
-- Private package current record structure definition
--
g_old_rec		g_rec_type;
--
-- Global package name
--
g_package		varchar2(33)	:= '  OTA_TBD_API.';
--
-- Global api dml status
--
g_api_dml		boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------tatus >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated or hr_api.child_integrity_violated has
--   been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--
-- Pre Conditions:
--   Either hr_api.check_integrity_violated, hr_api.parent_integrity_violated
--   or hr_api.child_integrity_violated has been raised with the subsequent
--   stripping of the constraint name from the generated error message text.
--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
	--
	hr_utility.set_location('Entering:'||l_proc, 5);
	--
	--	Foreign keys
	--
	If (p_constraint_name = 'OTA_BOOKING_DEALS_FK1') Then
           -- Business Group ID
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13467_TBD_INVALID_KEY');
		FND_MESSAGE.SET_TOKEN ('STEP', '1');
	ElsIf (p_constraint_name = 'OTA_BOOKING_DEALS_FK2') Then
           -- Price List
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13467_TBD_INVALID_KEY');
		FND_MESSAGE.SET_TOKEN ('STEP', '2');
	ElsIf (p_constraint_name = 'OTA_BOOKING_DEALS_FK3') Then
           -- Activity
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13467_TBD_INVALID_KEY');
		FND_MESSAGE.SET_TOKEN ('STEP', '3');
	ElsIf (p_constraint_name = 'OTA_BOOKING_DEALS_FK4') Then
           -- Event
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13467_TBD_INVALID_KEY');
		FND_MESSAGE.SET_TOKEN ('STEP', '4');
	--
	--	Primary key
	--
	ElsIf (p_constraint_name = 'OTA_BOOKING_DEALS_PK') Then
		hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PROCEDURE', l_proc);
		hr_utility.set_message_token('STEP','25');
		hr_utility.raise_error;
	--
	--	Check constraints
	--
	elsif (P_CONSTRAINT_NAME = 'OTA_TBD_DATES_SEQ') then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13312_GEN_DATE_ORDER');
	ElsIf (p_constraint_name = 'OTA_TBD_CHECK_DISCOUNT_CONTEXT') Then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13242_TBD_DISCOUNT');
	ElsIf (p_constraint_name = 'OTA_TBD_CHECK_PREPURCH_CONTEXT') Then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13241_TBD_PREPURCH');
	elsif (p_constraint_name = 'OTA_TBD_EXCLUSIVE_CONTEXT') Then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13231_TBD_EXCLUSIVE');
	elsif (p_constraint_name = 'OTA_TBD_TYPE_CHK') Then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13243_TBD_TYPE');
	--
	--	Other errors (see below).
	--
	elsif (P_CONSTRAINT_NAME = 'DUPLICATE_NAME') then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13468_TBD_NOT_UNIQUE');
	elsif (P_CONSTRAINT_NAME = 'INVALID_APPROVER') then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13393_TBD_APPROVER');
	elsif (P_CONSTRAINT_NAME = 'OTA_TBD_BUS_GROUPS') then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13244_TBD_BUS_GROUP');
	elsif (P_CONSTRAINT_NAME = 'OTA_TBD_DATES_TPL') Then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13211_TBD_DATES_TPL');
	elsif (p_constraint_name = 'OTA_TBD_DATES_EVT') Then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13212_TBD_DATES_EVT');
	elsif (p_constraint_name = 'OTA_TBD_DATES_TAV') Then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13213_TBD_DATES_TAV');
	elsif (P_CONSTRAINT_NAME = 'OTA_TBD_CATEGORY') then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13245_TBD_CATEGORY');
	elsif (P_CONSTRAINT_NAME = 'OTA_TBD_FINANCE_LINES') then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13246_TBD_FINANCE_LINES');
	elsif (P_CONSTRAINT_NAME = 'NON-TRANSFERABLE BASIS') then
		FND_MESSAGE.SET_NAME  ('OTA', 'OTA_13220_TBD_NON_TRANSFER');
	--
	--	?
	--
	Else
		FND_MESSAGE.SET_NAME  (801, 'HR_6153_ALL_PROCEDURE_FAIL');
		FND_MESSAGE.SET_TOKEN ('PROCEDURE', l_proc);
		FND_MESSAGE.SET_TOKEN ('STEP','35');
	End If;
	--
	FND_MESSAGE.RAISE_ERROR;
	--
	hr_utility.set_location(' Leaving:'||l_proc, 10);
	--
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< g_old_rec_current >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the current
--   row from the database for the specified primary key provided that the
--   primary key exists and is valid and does not already match the current
--   g_old_rec.
--   The function will always return a TRUE value if the g_old_rec is
--   populated with the current row. A FALSE value will be returned if any of
--   the primary key arguments are null.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec is
--   current.
--   A value of FALSE will be returned if any of the primary key arguments
--   has a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function g_old_rec_current
  (
  p_booking_deal_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		booking_deal_id,
	customer_id,
	approved_by_person_id,
	business_group_id,
	name,
	object_version_number,
	start_date,
	category,
	comments,
	description,
	discount_percentage,
	end_date,
	number_of_places,
	LIMIT_EACH_EVENT_FLAG,
	overdraft_limit,
	type,
	price_list_id,
	activity_version_id,
	event_id,
	tbd_information_category,
	tbd_information1,
	tbd_information2,
	tbd_information3,
	tbd_information4,
	tbd_information5,
	tbd_information6,
	tbd_information7,
	tbd_information8,
	tbd_information9,
	tbd_information10,
	tbd_information11,
	tbd_information12,
	tbd_information13,
	tbd_information14,
	tbd_information15,
	tbd_information16,
	tbd_information17,
	tbd_information18,
	tbd_information19,
	tbd_information20
    from	ota_booking_deals
    where	booking_deal_id = p_booking_deal_id;
--
  l_proc	varchar2(72)	:= g_package||'g_old_rec_current';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_booking_deal_id is null or
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_booking_deal_id = g_old_rec.booking_deal_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End g_old_rec_current;
--
--
-- ----------------------------------------------------------------------------
-- --------------------------------< CHECK_DATES_CONFLICT >--------------------
-- ----------------------------------------------------------------------------
--
--      Checks if booking deal dates have been changed that they do not
--      validate any student enrollments.
--
procedure check_dates_conflict(p_booking_deal_id in number,
			       p_start_date      in date,
			       p_end_date        in date) is
  --
  l_before number;
  l_after  number;
  l_proc   varchar2(72)	:= g_package||'check_dates_conflict';
  --
  cursor c_check_enrollments is
    select nvl(count(a.booking_deal_id),0)
    from   ota_finance_lines a
    where  p_booking_deal_id = booking_deal_id
    and    cancelled_flag = 'N';
  --
  -- Cursor to check how many records will come back if date changes
  -- applied
  --
  cursor c_check_date_change is
    select nvl(count(a.booking_deal_id),0)
    from   ota_finance_lines     a,
	   ota_delegate_bookings b,
	   ota_events c
    where  a.booking_deal_id = p_booking_deal_id
    and    a.booking_id      = b.booking_id
    and    b.event_id        = c.event_id
    and    p_start_date <= nvl(c.course_start_date,p_start_date)
    and    nvl(p_end_date,hr_api.g_eot)
	   >= nvl(c.course_start_date,nvl(p_end_date,hr_api.g_eot))
    and    a.cancelled_flag = 'N';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.set_location('Booking Deal ID '||p_booking_deal_id,10);
  hr_utility.set_location('Start Date'||p_start_date,10);
  hr_utility.set_location('End Date'||p_end_date,10);
  --
  -- Get number of enrollments currently using booking deal
  --
  open c_check_enrollments;
    --
    fetch c_check_enrollments into l_before;
    --
  close c_check_enrollments;
  --
  -- Get number of enrollments that will be unaffected by new booking deal
  --
  open c_check_date_change;
    --
    fetch c_check_date_change into l_after;
    --
  close c_check_date_change;
  --
  if l_after <> l_before then
    --
    -- Change results in some bookings becoming invalid
    --
    fnd_message.set_name('OTA','OTA_13596_INVALID_ENROLLMENTS');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end check_dates_conflict;
-- ----------------------------------------------------------------------------
-- -----------------------------< SUM_AMOUNT    >------------------------------
-- ----------------------------------------------------------------------------
function SUM_AMOUNT
       (P_BOOKING_DEAL_ID                    in number,
        P_TYPE                               in varchar2,
        P_LINE_TYPE                          in varchar2
        ) return number is
--
W_UNITS_PURCHASED                                               number;
W_MONEY_PURCHASED                                               number;
--
cursor C1 is
        select sum (TFL.UNITARY_AMOUNT),
               sum (TFL.MONEY_AMOUNT)
          from OTA_FINANCE_LINES                        TFL
          where TFL.BOOKING_DEAL_ID               (+) = P_BOOKING_DEAL_ID
            and (    (TFL.CANCELLED_FLAG             is null)
                 or  (TFL.CANCELLED_FLAG              = 'N' ))
            and TFL.LINE_TYPE = P_LINE_TYPE;
--
begin
        --
        open C1;
        fetch C1
          into W_UNITS_PURCHASED,
               W_MONEY_PURCHASED;
        close C1;
        --
        if P_TYPE = 'T' then
           return (W_UNITS_PURCHASED);
        elsif P_TYPE = 'M' then
           return (W_MONEY_PURCHASED);
        end if;
end SUM_AMOUNT;
-- ----------------------------------------------------------------------------
-- -----------------------------< TFL_PURCHASED >------------------------------
-- ----------------------------------------------------------------------------
--
--	Function returns the purchased amount from OTA_FINANCE_LINES for the
--	BOOKING_DEAL_ID supplied in uniTs or Money as requested.
--
function TFL_PURCHASED (
	P_BOOKING_DEAL_ID			     in	number,
	P_TYPE					     in	varchar2
	) return number is
--
begin
	--
        return (sum_amount(P_BOOKING_DEAL_ID
                          ,P_TYPE
                          ,'P'));
	--
end TFL_PURCHASED;
--
-- ----------------------------------------------------------------------------
-- -----------------------------< TFL_BALANCE >--------------------------------
-- ----------------------------------------------------------------------------
--
--	Function returns the outstanding balance from OTA_FINANCE_LINES for the
--	BOOKING_DEAL_ID supplied in uniTs or Money as requested.
--
function TFL_BALANCE (
	P_BOOKING_DEAL_ID			     in	number,
	P_TYPE					     in	varchar2
	) return number is
--
begin
	--
        return (nvl(sum_amount(P_BOOKING_DEAL_ID
                          ,P_TYPE
                          ,'P'),0)
              - nvl(sum_amount(P_BOOKING_DEAL_ID
                          ,P_TYPE
                          ,'E'),0)
               );
	--
end TFL_BALANCE;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< TFL_FLAG >---------------------------------
-- ----------------------------------------------------------------------------
--
--	Returns 'TRUE' if OTA_FINANCE_LINES exist for the BOOKING_DEAL_ID,
--	or null	if not present.
--
function TFL_FLAG (
	P_BOOKING_DEAL_ID			     in	number
	) return varchar2 is
--
W_FLAG							varchar2 (4);
--
cursor C1 is
	select 'TRUE'
	  from OTA_FINANCE_LINES			TFL
	  where TFL.BOOKING_DEAL_ID		  (+) =	P_BOOKING_DEAL_ID
	    and (    (TFL.CANCELLED_FLAG	     is	null)
	         or  (TFL.CANCELLED_FLAG	      = 'N' ));
--
begin
	--
	open C1;
	fetch C1
	  into W_FLAG;
	if (C1%notfound) then
		W_FLAG := null;
	end if;
	close C1;
	--
	return (W_FLAG);
	--
end TFL_FLAG;
--
-- ----------------------------------------------------------------------------
-- -----------------------------< CHECK_UNIQUE_NAME >--------------------------
-- ----------------------------------------------------------------------------
--
--	Just what the name would imply.
--  07/11/95 - Changed to ensure that booking deals are unique within
--             Customer. If the Customer_id is null then not Customer can
--             use the Deal Name.
--
procedure CHECK_UNIQUE_NAME (
	P_BUSINESS_GROUP_ID			     in	number,
	P_BOOKING_DEAL_ID			     in	number,
	P_NAME					     in	varchar2,
        P_CUSTOMER_ID                                in varchar2
	) is
--
W_FLAG							number (1);
W_PROCEDURE						varchar2 (72)
	:= G_PACKAGE || 'CHECK_UNIQUE_NAME';
W_UNIQUE						boolean;
--
cursor C1 is
	select 1
	  from OTA_BOOKING_DEALS			TBD
	  where TBD.BUSINESS_GROUP_ID+0      =	P_BUSINESS_GROUP_ID
	    and upper (TBD.NAME)		      =	upper (P_NAME)
            and  (p_customer_id is not null and
                 (customer_id is null or
                 (customer_id is not null and
                  customer_id = p_customer_id))
               or (p_customer_id is null))
	    and (    (P_BOOKING_DEAL_ID		     is null             )
	         or  (TBD.BOOKING_DEAL_ID	     <> P_BOOKING_DEAL_ID));
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	open C1;
	fetch C1
	  into W_FLAG;
	if (C1%found) then
		CONSTRAINT_ERROR ('DUPLICATE_NAME');
	end if;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 99);
	--
end CHECK_UNIQUE_NAME;
--
-- ----------------------------------------------------------------------------
-- --------------------------------< CHECK_APPROVER >--------------------------
-- ----------------------------------------------------------------------------
--
--	The person approving the booking deal must be an employee when the
--	deal first becomes valid.
--
procedure CHECK_APPROVER ( P_APPROVED_BY_PERSON_ID in number) is
--
W_FLAG							number (1);
W_PROCEDURE						varchar2 (72)
	:= G_PACKAGE || 'CHECK_APPROVER';
W_VALID							boolean;
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	if (P_APPROVED_BY_PERSON_ID is not null) then
            if not ota_general.check_fnd_user(p_approved_by_person_id) then
               fnd_message.set_name ('OTA', 'OTA_13281_TFH_AUTHORIZER');
               fnd_message.raise_error;
            end if;

	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 99);
        --
end CHECK_APPROVER;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_PREPURCH_CONTEXT >-------------------
-- ----------------------------------------------------------------------------
--
--      If the TYPE is 'P' (Pre-purchase) then the NUMBER_OF_PLACES must be
--      null and the PRICE_LIST_ID must be populated.
--
procedure CHECK_PREPURCH_CONTEXT (
	P_NUMBER_OF_PLACES			     in	number,
	P_LIMIT_EACH_EVENT_FLAG			     in	varchar2,
	P_PRICE_LIST_ID				     in	number
	) is
--
W_PROCEDURE						varchar2 (72)
	:= G_PACKAGE || 'CHECK_PREPURCH_CONTEXT';
--
function VALID_PREPURCH_CONTEXT (
	P_NUMBER_OF_PLACES			     in	number,
	P_LIMIT_EACH_EVENT_FLAG			     in	varchar2,
	P_PRICE_LIST_ID				     in	number
	) return boolean is
begin
	--
	if (    (P_NUMBER_OF_PLACES      is null    )
	    and (P_LIMIT_EACH_EVENT_FLAG is null    )
	    and (P_PRICE_LIST_ID         is not null)) then
		return (true);
	else
		return (false);
	end if;
	--
end VALID_PREPURCH_CONTEXT;
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	if (not VALID_PREPURCH_CONTEXT (
			P_NUMBER_OF_PLACES	     =>	P_NUMBER_OF_PLACES,
			P_LIMIT_EACH_EVENT_FLAG	     =>	P_LIMIT_EACH_EVENT_FLAG,
			P_PRICE_LIST_ID		     =>	P_PRICE_LIST_ID)) then
		CONSTRAINT_ERROR ('OTA_TBD_CHECK_PREPURCH_CONTEXT');
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_PREPURCH_CONTEXT;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_DISCOUNT_CONTEXT >-------------------
-- ----------------------------------------------------------------------------
--
--      If the TYPE is 'D' (Discount) then the DISCOUNT_PERCENTAGE must be
--      populated and the OVERDRAFT_LIMIT must be null.
--
procedure CHECK_DISCOUNT_CONTEXT (
	P_DISCOUNT_PERCENTAGE			     in	number,
	P_OVERDRAFT_LIMIT			     in	number
	) is
--
W_PROCEDURE						varchar2 (72)
	:= G_PACKAGE || 'CHECK_DISCOUNT_CONTEXT';
--
function VALID_DISCOUNT_CONTEXT (
	P_DISCOUNT_PERCENTAGE			     in	number,
	P_OVERDRAFT_LIMIT			     in	number
	) return boolean is
begin
	--
	if ((P_DISCOUNT_PERCENTAGE is not null) and
	    (P_OVERDRAFT_LIMIT     is     null)) then
		return (true);
	else
		return (false);
	end if;
	--
end VALID_DISCOUNT_CONTEXT;
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	if (not VALID_DISCOUNT_CONTEXT (
			P_DISCOUNT_PERCENTAGE	     =>	P_DISCOUNT_PERCENTAGE,
			P_OVERDRAFT_LIMIT	     =>	P_OVERDRAFT_LIMIT)) then
		CONSTRAINT_ERROR ('OTA_TBD_CHECK_DISCOUNT_CONTEXT');
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_DISCOUNT_CONTEXT;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_DATES_TPL >--------------------------
-- ----------------------------------------------------------------------------
--
--      The start and end dates must be within the boundaries of the start and
--      end dates defined on the price list.
--
procedure CHECK_DATES_TPL (
        P_PRICE_LIST_ID                      in number,
	P_BUSINESS_GROUP_ID		     in	number,
        P_START_DATE                         in date,
        P_END_DATE                           in date
        ) is
  --
  W_PROCEDURE                                   varchar2 (72)
        := G_PACKAGE || 'CHECK_DATES_TPL';
  --
  W_BUSINESS_GROUP_ID				number (9);
  W_TPL_START_DATE                              date;
  W_TPL_END_DATE                                date;
  --
  cursor C1 is
    select TPL.BUSINESS_GROUP_ID,
	   nvl (TPL.START_DATE, hr_api.g_sot),
           nvl (TPL.END_DATE,   hr_api.g_eot)
      from OTA_PRICE_LISTS                      TPL
      where TPL.PRICE_LIST_ID                 = P_PRICE_LIST_ID;
  --
begin
  --
  HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
  --
  open C1;
  fetch C1
    into W_BUSINESS_GROUP_ID,
         W_TPL_START_DATE,
         W_TPL_END_DATE;
  if (C1%notfound) then
    close C1;
    CONSTRAINT_ERROR ('OTA_BOOKING_DEALS_FK3');
  end if;
  close C1;
  --
  if (W_BUSINESS_GROUP_ID <> P_BUSINESS_GROUP_ID) then
    CONSTRAINT_ERROR ('OTA_TBD_BUS_GROUPS');
  end if;
  --
  if (    (P_START_DATE not between W_TPL_START_DATE
                                and W_TPL_END_DATE  )
      or  (nvl (P_END_DATE, P_START_DATE)
                        not between W_TPL_START_DATE
                                and W_TPL_END_DATE  )) then
    CONSTRAINT_ERROR ('OTA_TBD_DATES_TPL');
  end if;
  --
  HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
  --
end CHECK_DATES_TPL;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_EVENT >------------------------------
-- ----------------------------------------------------------------------------
--
--	The event BUSINESS_GROUP_ID must be the same as the booking deals.
--
--	The event type must be 'PROGRAMME' or 'SCHEDULED'.
--
--      The start and end dates must be within the boundaries of the course
--      start and end dates defined on the event.
--
procedure CHECK_EVENT (
	P_EVENT_ID				     in	number,
	P_BUSINESS_GROUP_ID			     in	number,
	P_START_DATE				     in	date,
	P_END_DATE				     in	date,
        P_NUMBER_OF_PLACES                           in number
	) is
--
W_PROCEDURE						varchar2 (72)
	:= G_PACKAGE || 'CHECK_EVENT';
--
W_BUSINESS_GROUP_ID					number (9);
W_EVENT_TYPE						varchar2 (30);
W_EVT_START_DATE					date;
W_EVT_END_DATE						date;
W_MAX_ATTENDEES                                         number;
W_PRICE_BASIS                                           varchar2(30);
--
cursor C1 is
	select EVT.BUSINESS_GROUP_ID,
	       EVT.EVENT_TYPE,
	       nvl (EVT.COURSE_START_DATE,hr_api.g_sot),
	       nvl (EVT.COURSE_END_DATE  ,hr_api.g_eot),
               maximum_attendees,
               price_basis
	  from OTA_EVENTS				EVT
	  where EVT.EVENT_ID			      =	P_EVENT_ID;
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	--	Get event details
	--
	open C1;
	fetch C1
	  into W_BUSINESS_GROUP_ID,
	       W_EVENT_TYPE,
	       W_EVT_START_DATE,
	       W_EVT_END_DATE,
               W_MAX_ATTENDEES,
               W_PRICE_BASIS;
	if (C1%notfound) then
		close C1;
		CONSTRAINT_ERROR ('OTA_BOOKING_DEALS_FK5');
	end if;
	close C1;
	--
	--	Business group
	--
	if (W_BUSINESS_GROUP_ID <> P_BUSINESS_GROUP_ID) then
		CONSTRAINT_ERROR ('OTA_TBD_BUS_GROUPS');
	end if;
	--
	--	Event type
	--
	if (W_EVENT_TYPE not in ('PROGRAMME', 'SCHEDULED')) then
		CONSTRAINT_ERROR ('OTA_TBS_EVENT_TYPE');
	end if;
	--
	--	Dates within course dates
	--
	if (    (P_START_DATE not between W_EVT_START_DATE
	                              and W_EVT_END_DATE  )
	    or  (nvl (P_END_DATE, P_START_DATE)
	                      not between W_EVT_START_DATE
	                              and W_EVT_END_DATE  )) then
		CONSTRAINT_ERROR ('OTA_TBD_DATES_EVT');
	end if;
	--
        if p_number_of_places is not null and
           w_max_attendees is not null and
           p_number_of_places > w_max_attendees then
             fnd_message.set_name('OTA','OTA_13496_TBD_PLACES_GT_EVENT');
             fnd_message.raise_error;
        end if;
        --
        if w_price_basis not in ('C','S') then
           fnd_message.set_name('OTA','OTA_13497_TBD_PRICE_BASIS');
           fnd_message.raise_error;
        end if;
        --
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_EVENT;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_DATES_TAV >--------------------------
-- ----------------------------------------------------------------------------
--
--      The start and end dates must be within the boundaries of the start and
--      end dates defined on the activity version.
--
procedure CHECK_DATES_TAV (
        P_ACTIVITY_VERSION_ID                in number,
        P_START_DATE                         in date,
        P_END_DATE                           in date
        ) is
  --
  W_PROCEDURE                                   varchar2 (72)
        := G_PACKAGE || 'CHECK_DATES_TAV';
  --
  W_TAV_START_DATE                              date;
  W_TAV_END_DATE                                date;
  --
  cursor C1 is
    select nvl (TAV.START_DATE, hr_api.g_sot),
           nvl (TAV.END_DATE,   hr_api.g_eot)
      from OTA_ACTIVITY_VERSIONS                TAV
      where TAV.ACTIVITY_VERSION_ID           = P_ACTIVITY_VERSION_ID;
  --
begin
  --
  HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
  --
  open C1;
  fetch C1
    into W_TAV_START_DATE,
         W_TAV_END_DATE;
  if (C1%notfound) then
    close C1;
    CONSTRAINT_ERROR ('OTA_BOOKING_DEALS_FK4');
  end if;
  close C1;
  --
  if (    (P_START_DATE not between W_TAV_START_DATE
                                and W_TAV_END_DATE  )
      or  (nvl (P_END_DATE, P_START_DATE)
                        not between W_TAV_START_DATE
                                and W_TAV_END_DATE  )) then
    CONSTRAINT_ERROR ('OTA_TBD_DATES_TAV');
  end if;
  --
  HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
  --
end;
--
-- ----------------------------------------------------------------------------
-- -----------------------------< CHECK_CATEGORY >-----------------------------
-- ----------------------------------------------------------------------------
--
--	The category must be in the domain 'CATEGORY' and have an
--	OTA_CATEGORY_USAGES row of TYPE 'P'(ackage).
--
procedure CHECK_CATEGORY (
	P_BUSINESS_GROUP_ID		     in	number,
	P_CATEGORY			     in	varchar2
	) is
--
W_FLAG						number (1);
W_PROCEDURE					varchar2 (72)
	:= G_PACKAGE || 'CHECK_CATEGORY';
W_VALID						boolean;
--
cursor C1 is
	select 1
	  from OTA_CATEGORY_USAGES		TCU
	  where TCU.BUSINESS_GROUP_ID	      =	P_BUSINESS_GROUP_ID
	    and TCU.CATEGORY_usage_id      =	P_CATEGORY
	    and TCU.TYPE		      = 'D';
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	/*OTA_GENERAL.CHECK_DOMAIN_VALUE (
		P_DOMAIN_TYPE		     => 'ACTIVITY_CATEGORY',
		P_DOMAIN_VALUE		     => P_CATEGORY);*/
	--
	open C1;
	fetch C1
	  into W_FLAG;
	W_VALID := C1%found;
	close C1;
	--
	if (not W_VALID) then
		CONSTRAINT_ERROR ('OTA_TBD_CATEGORY');
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_CATEGORY;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< VALIDITY_CHECK >---------------------------
-- ----------------------------------------------------------------------------
--
--      Apply the above checks.
--
procedure VALIDITY_CHECK (
        P_REC					     in	G_REC_TYPE
        ) is
--
W_PROCEDURE						varchar2 (72)
	:= G_PACKAGE || 'VALIDITY_CHECK';
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	--	Name must be unique to business group
	--
	CHECK_UNIQUE_NAME (
		P_BUSINESS_GROUP_ID    => P_REC.BUSINESS_GROUP_ID,
		P_BOOKING_DEAL_ID      => P_REC.BOOKING_DEAL_ID,
		P_NAME		       => P_REC.NAME,
                p_customer_id          => p_rec.customer_id);
	--
	--	Approved by
	--
	CHECK_APPROVER (
		P_APPROVED_BY_PERSON_ID	=> P_REC.APPROVED_BY_PERSON_ID);
	--
	--	Booking deal TYPE
	--
	if (P_REC.TYPE = 'P') then
		CHECK_PREPURCH_CONTEXT (
			P_NUMBER_OF_PLACES	     =>	P_REC.NUMBER_OF_PLACES,
			P_LIMIT_EACH_EVENT_FLAG	     =>	P_REC.LIMIT_EACH_EVENT_FLAG,
			P_PRICE_LIST_ID              =>	P_REC.PRICE_LIST_ID);
	elsif (P_REC.TYPE = 'D') then
		CHECK_DISCOUNT_CONTEXT (
			P_DISCOUNT_PERCENTAGE	     =>	P_REC.DISCOUNT_PERCENTAGE,
			P_OVERDRAFT_LIMIT	     =>	P_REC.OVERDRAFT_LIMIT);
	else
		CONSTRAINT_ERROR ('OTA_TBD_TYPE_CHK');
	end if;
	--
	--	Exclusivity
	--
	if (P_REC.PRICE_LIST_ID is not null) then
		--
		--	PRICE_LIST_ID
		--
		if (    (P_REC.EVENT_ID		     is not null)
		    or  (P_REC.ACTIVITY_VERSION_ID   is not null)
		    or  (P_REC.CATEGORY              is not null)) then
			CONSTRAINT_ERROR ('OTA_TBD_EXCLUSIVE_CONTEXT');
		end if;
		--
		CHECK_DATES_TPL (
			P_PRICE_LIST_ID              => P_REC.PRICE_LIST_ID,
			P_BUSINESS_GROUP_ID	     =>	P_REC.BUSINESS_GROUP_ID,
			P_START_DATE                 => P_REC.START_DATE,
        		P_END_DATE                   => P_REC.END_DATE);
		--
	elsif (P_REC.EVENT_ID is not null) then
		--
		--	EVENT_ID
		--
		if ((P_REC.ACTIVITY_VERSION_ID is not null) or
		    (P_REC.CATEGORY            is not null)) then
			CONSTRAINT_ERROR ('OTA_TBD_EXCLUSIVE_CONTEXT');
		end if;
		--
		CHECK_EVENT (
			P_EVENT_ID		     =>	P_REC.EVENT_ID,
			P_BUSINESS_GROUP_ID	     =>	P_REC.BUSINESS_GROUP_ID,
			P_START_DATE		     =>	P_REC.START_DATE,
			P_END_DATE		     =>	P_REC.END_DATE,
                        p_number_of_places           => p_rec.number_of_places);
		--
	elsif (P_REC.ACTIVITY_VERSION_ID is not null) then
		--
		--	ACTIVITY_VERSION_ID
		--
		if (P_REC.CATEGORY            is not null) then
			CONSTRAINT_ERROR ('OTA_TBD_EXCLUSIVE_CONTEXT');
		end if;
		--
		CHECK_DATES_TAV (
			P_ACTIVITY_VERSION_ID	     =>	P_REC.ACTIVITY_VERSION_ID,
			P_START_DATE		     =>	P_REC.START_DATE,
			P_END_DATE		     =>	P_REC.END_DATE);
		--
	elsif (P_REC.CATEGORY is not null) then
		--
		--	Category
		--
		CHECK_CATEGORY (
			P_BUSINESS_GROUP_ID	     => P_REC.BUSINESS_GROUP_ID,
			P_CATEGORY		     => P_REC.CATEGORY);
		--
	else
		--
		--	Must pick one
		--
		CONSTRAINT_ERROR ('OTA_TBD_EXCLUSIVE_CONTEXT');
		--
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end;
--
-- ----------------------------------------------------------------------------
-- ---------------------------------< TFL_LINES >------------------------------
-- ----------------------------------------------------------------------------
--
function TFL_LINES (
	P_BOOKING_DEAL_ID		     in	number
	) return boolean is
  --
  W_PROCEDURE					varchar2 (72)
	:= G_PACKAGE || 'TFL_LINES';
  --
  W_LINES                                       varchar2 (3);
  --
  cursor C1 is
    select 'YES'
      from OTA_FINANCE_LINES                    TFL
      where TFL.BOOKING_DEAL_ID               = P_BOOKING_DEAL_ID;
  --
begin
  --
  HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
  --
  open C1;
  fetch C1
    into W_LINES;
  if (C1%notfound) then
    W_LINES := 'NO';
  end if;
  close C1;
  --
  if (W_LINES = 'YES') then
    return (true);
  else
    return (false);
  end if;
  --
end TFL_LINES;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_booking_deals
  --
  insert into ota_booking_deals
  (	booking_deal_id,
	customer_id,
	approved_by_person_id,
	business_group_id,
	name,
	object_version_number,
	start_date,
	category,
	comments,
	description,
	discount_percentage,
	end_date,
	number_of_places,
	LIMIT_EACH_EVENT_FLAG,
	overdraft_limit,
	type,
	price_list_id,
	activity_version_id,
	event_id,
	tbd_information_category,
	tbd_information1,
	tbd_information2,
	tbd_information3,
	tbd_information4,
	tbd_information5,
	tbd_information6,
	tbd_information7,
	tbd_information8,
	tbd_information9,
	tbd_information10,
	tbd_information11,
	tbd_information12,
	tbd_information13,
	tbd_information14,
	tbd_information15,
	tbd_information16,
	tbd_information17,
	tbd_information18,
	tbd_information19,
	tbd_information20
  )
  Values
  (	p_rec.booking_deal_id,
	p_rec.customer_id,
	p_rec.approved_by_person_id,
	p_rec.business_group_id,
	p_rec.name,
	p_rec.object_version_number,
	p_rec.start_date,
	p_rec.category,
	p_rec.comments,
	p_rec.description,
	p_rec.discount_percentage,
	p_rec.end_date,
	p_rec.number_of_places,
	P_REC.LIMIT_EACH_EVENT_FLAG,
	p_rec.overdraft_limit,
	p_rec.type,
	p_rec.price_list_id,
	p_rec.activity_version_id,
	p_rec.event_id,
	p_rec.tbd_information_category,
	p_rec.tbd_information1,
	p_rec.tbd_information2,
	p_rec.tbd_information3,
	p_rec.tbd_information4,
	p_rec.tbd_information5,
	p_rec.tbd_information6,
	p_rec.tbd_information7,
	p_rec.tbd_information8,
	p_rec.tbd_information9,
	p_rec.tbd_information10,
	p_rec.tbd_information11,
	p_rec.tbd_information12,
	p_rec.tbd_information13,
	p_rec.tbd_information14,
	p_rec.tbd_information15,
	p_rec.tbd_information16,
	p_rec.tbd_information17,
	p_rec.tbd_information18,
	p_rec.tbd_information19,
	p_rec.tbd_information20
  );
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_booking_deals Row
  --
  update ota_booking_deals
  set
  booking_deal_id                   = p_rec.booking_deal_id,
  customer_id                       = p_rec.customer_id,
  approved_by_person_id             = p_rec.approved_by_person_id,
  business_group_id                 = p_rec.business_group_id,
  name                              = p_rec.name,
  object_version_number             = p_rec.object_version_number,
  start_date                        = p_rec.start_date,
  category                          = p_rec.category,
  comments                          = p_rec.comments,
  description                       = p_rec.description,
  discount_percentage               = p_rec.discount_percentage,
  end_date                          = p_rec.end_date,
  number_of_places                  = p_rec.number_of_places,
  LIMIT_EACH_EVENT_FLAG		    = P_REC.LIMIT_EACH_EVENT_FLAG,
  overdraft_limit                   = p_rec.overdraft_limit,
  type                              = p_rec.type,
  price_list_id                     = p_rec.price_list_id,
  activity_version_id               = p_rec.activity_version_id,
  event_id                          = p_rec.event_id,
  tbd_information_category          = p_rec.tbd_information_category,
  tbd_information1                  = p_rec.tbd_information1,
  tbd_information2                  = p_rec.tbd_information2,
  tbd_information3                  = p_rec.tbd_information3,
  tbd_information4                  = p_rec.tbd_information4,
  tbd_information5                  = p_rec.tbd_information5,
  tbd_information6                  = p_rec.tbd_information6,
  tbd_information7                  = p_rec.tbd_information7,
  tbd_information8                  = p_rec.tbd_information8,
  tbd_information9                  = p_rec.tbd_information9,
  tbd_information10                 = p_rec.tbd_information10,
  tbd_information11                 = p_rec.tbd_information11,
  tbd_information12                 = p_rec.tbd_information12,
  tbd_information13                 = p_rec.tbd_information13,
  tbd_information14                 = p_rec.tbd_information14,
  tbd_information15                 = p_rec.tbd_information15,
  tbd_information16                 = p_rec.tbd_information16,
  tbd_information17                 = p_rec.tbd_information17,
  tbd_information18                 = p_rec.tbd_information18,
  tbd_information19                 = p_rec.tbd_information19,
  tbd_information20                 = p_rec.tbd_information20
  where booking_deal_id = p_rec.booking_deal_id;
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of this
--   procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ota_booking_deals row.
  --
  delete from ota_booking_deals
  where booking_deal_id = p_rec.booking_deal_id;
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_booking_deals_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.booking_deal_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_booking_deal_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	booking_deal_id,
	customer_id,
	approved_by_person_id,
	business_group_id,
	name,
	object_version_number,
	start_date,
	category,
	comments,
	description,
	discount_percentage,
	end_date,
	number_of_places,
	LIMIT_EACH_EVENT_FLAG,
	overdraft_limit,
	type,
	price_list_id,
	activity_version_id,
	event_id,
	tbd_information_category,
	tbd_information1,
	tbd_information2,
	tbd_information3,
	tbd_information4,
	tbd_information5,
	tbd_information6,
	tbd_information7,
	tbd_information8,
	tbd_information9,
	tbd_information10,
	tbd_information11,
	tbd_information12,
	tbd_information13,
	tbd_information14,
	tbd_information15,
	tbd_information16,
	tbd_information17,
	tbd_information18,
	tbd_information19,
	tbd_information20
    from	ota_booking_deals
    where	booking_deal_id = p_booking_deal_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ota_booking_deals');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_booking_deal_id               in number,
	p_customer_id                   in number,
	p_approved_by_person_id         in number,
	p_business_group_id             in number,
	p_name                          in varchar2,
	p_object_version_number         in number,
	p_start_date                    in date,
	p_category                      in varchar2,
	p_comments                      in varchar2,
	p_description                   in varchar2,
	p_discount_percentage           in number,
	p_end_date                      in date,
	p_number_of_places              in number,
	P_LIMIT_EACH_EVENT_FLAG         in varchar2,
	p_overdraft_limit               in number,
	p_type                          in varchar2,
	p_price_list_id                 in number,
	p_activity_version_id           in number,
	p_event_id                      in number,
	p_tbd_information_category      in varchar2,
	p_tbd_information1              in varchar2,
	p_tbd_information2              in varchar2,
	p_tbd_information3              in varchar2,
	p_tbd_information4              in varchar2,
	p_tbd_information5              in varchar2,
	p_tbd_information6              in varchar2,
	p_tbd_information7              in varchar2,
	p_tbd_information8              in varchar2,
	p_tbd_information9              in varchar2,
	p_tbd_information10             in varchar2,
	p_tbd_information11             in varchar2,
	p_tbd_information12             in varchar2,
	p_tbd_information13             in varchar2,
	p_tbd_information14             in varchar2,
	p_tbd_information15             in varchar2,
	p_tbd_information16             in varchar2,
	p_tbd_information17             in varchar2,
	p_tbd_information18             in varchar2,
	p_tbd_information19             in varchar2,
	p_tbd_information20             in varchar2
	)
	Return g_rec_type is
--
  l_rec	g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.booking_deal_id                  := p_booking_deal_id;
  l_rec.customer_id                      := p_customer_id;
  l_rec.approved_by_person_id            := p_approved_by_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.name                             := p_name;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.start_date                       := p_start_date;
  l_rec.category                         := p_category;
  l_rec.comments                         := p_comments;
  l_rec.description                      := p_description;
  l_rec.discount_percentage              := p_discount_percentage;
  l_rec.end_date                         := p_end_date;
  l_rec.number_of_places                 := p_number_of_places;
  L_REC.LIMIT_EACH_EVENT_FLAG 		 := P_LIMIT_EACH_EVENT_FLAG;
  l_rec.overdraft_limit                  := p_overdraft_limit;
  l_rec.type                             := p_type;
  l_rec.price_list_id                    := p_price_list_id;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.event_id                         := p_event_id;
  l_rec.tbd_information_category         := p_tbd_information_category;
  l_rec.tbd_information1                 := p_tbd_information1;
  l_rec.tbd_information2                 := p_tbd_information2;
  l_rec.tbd_information3                 := p_tbd_information3;
  l_rec.tbd_information4                 := p_tbd_information4;
  l_rec.tbd_information5                 := p_tbd_information5;
  l_rec.tbd_information6                 := p_tbd_information6;
  l_rec.tbd_information7                 := p_tbd_information7;
  l_rec.tbd_information8                 := p_tbd_information8;
  l_rec.tbd_information9                 := p_tbd_information9;
  l_rec.tbd_information10                := p_tbd_information10;
  l_rec.tbd_information11                := p_tbd_information11;
  l_rec.tbd_information12                := p_tbd_information12;
  l_rec.tbd_information13                := p_tbd_information13;
  l_rec.tbd_information14                := p_tbd_information14;
  l_rec.tbd_information15                := p_tbd_information15;
  l_rec.tbd_information16                := p_tbd_information16;
  l_rec.tbd_information17                := p_tbd_information17;
  l_rec.tbd_information18                := p_tbd_information18;
  l_rec.tbd_information19                := p_tbd_information19;
  l_rec.tbd_information20                := p_tbd_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy g_rec_type)
         Return g_rec_type is
--
  l_proc	  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.customer_id = hr_api.g_number) then
    p_rec.customer_id := g_old_rec.customer_id;
  End If;
  If (p_rec.approved_by_person_id = hr_api.g_number) then
    p_rec.approved_by_person_id := g_old_rec.approved_by_person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id := g_old_rec.business_group_id;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name := g_old_rec.name;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date := g_old_rec.start_date;
  End If;
  If (p_rec.category = hr_api.g_varchar2) then
    p_rec.category := g_old_rec.category;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments := g_old_rec.comments;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description := g_old_rec.description;
  End If;
  If (p_rec.discount_percentage = hr_api.g_number) then
    p_rec.discount_percentage := g_old_rec.discount_percentage;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date := g_old_rec.end_date;
  End If;
  If (p_rec.number_of_places = hr_api.g_number) then
    p_rec.number_of_places := g_old_rec.number_of_places;
  End If;
	if (P_REC.LIMIT_EACH_EVENT_FLAG  = HR_API.G_VARCHAR2) then
		P_REC.LIMIT_EACH_EVENT_FLAG := G_OLD_REC.LIMIT_EACH_EVENT_FLAG;
	end if;
  If (p_rec.overdraft_limit = hr_api.g_number) then
    p_rec.overdraft_limit := g_old_rec.overdraft_limit;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type := g_old_rec.type;
  End If;
  If (p_rec.price_list_id = hr_api.g_number) then
    p_rec.price_list_id := g_old_rec.price_list_id;
  End If;
  If (p_rec.activity_version_id = hr_api.g_number) then
    p_rec.activity_version_id := g_old_rec.activity_version_id;
  End If;
  If (p_rec.event_id = hr_api.g_number) then
    p_rec.event_id := g_old_rec.event_id;
  End If;
  If (p_rec.tbd_information_category = hr_api.g_varchar2) then
    p_rec.tbd_information_category := g_old_rec.tbd_information_category;
  End If;
  If (p_rec.tbd_information1 = hr_api.g_varchar2) then
    p_rec.tbd_information1 := g_old_rec.tbd_information1;
  End If;
  If (p_rec.tbd_information2 = hr_api.g_varchar2) then
    p_rec.tbd_information2 := g_old_rec.tbd_information2;
  End If;
  If (p_rec.tbd_information3 = hr_api.g_varchar2) then
    p_rec.tbd_information3 := g_old_rec.tbd_information3;
  End If;
  If (p_rec.tbd_information4 = hr_api.g_varchar2) then
    p_rec.tbd_information4 := g_old_rec.tbd_information4;
  End If;
  If (p_rec.tbd_information5 = hr_api.g_varchar2) then
    p_rec.tbd_information5 := g_old_rec.tbd_information5;
  End If;
  If (p_rec.tbd_information6 = hr_api.g_varchar2) then
    p_rec.tbd_information6 := g_old_rec.tbd_information6;
  End If;
  If (p_rec.tbd_information7 = hr_api.g_varchar2) then
    p_rec.tbd_information7 := g_old_rec.tbd_information7;
  End If;
  If (p_rec.tbd_information8 = hr_api.g_varchar2) then
    p_rec.tbd_information8 := g_old_rec.tbd_information8;
  End If;
  If (p_rec.tbd_information9 = hr_api.g_varchar2) then
    p_rec.tbd_information9 := g_old_rec.tbd_information9;
  End If;
  If (p_rec.tbd_information10 = hr_api.g_varchar2) then
    p_rec.tbd_information10 := g_old_rec.tbd_information10;
  End If;
  If (p_rec.tbd_information11 = hr_api.g_varchar2) then
    p_rec.tbd_information11 := g_old_rec.tbd_information11;
  End If;
  If (p_rec.tbd_information12 = hr_api.g_varchar2) then
    p_rec.tbd_information12 := g_old_rec.tbd_information12;
  End If;
  If (p_rec.tbd_information13 = hr_api.g_varchar2) then
    p_rec.tbd_information13 := g_old_rec.tbd_information13;
  End If;
  If (p_rec.tbd_information14 = hr_api.g_varchar2) then
    p_rec.tbd_information14 := g_old_rec.tbd_information14;
  End If;
  If (p_rec.tbd_information15 = hr_api.g_varchar2) then
    p_rec.tbd_information15 := g_old_rec.tbd_information15;
  End If;
  If (p_rec.tbd_information16 = hr_api.g_varchar2) then
    p_rec.tbd_information16 := g_old_rec.tbd_information16;
  End If;
  If (p_rec.tbd_information17 = hr_api.g_varchar2) then
    p_rec.tbd_information17 := g_old_rec.tbd_information17;
  End If;
  If (p_rec.tbd_information18 = hr_api.g_varchar2) then
    p_rec.tbd_information18 := g_old_rec.tbd_information18;
  End If;
  If (p_rec.tbd_information19 = hr_api.g_varchar2) then
    p_rec.tbd_information19 := g_old_rec.tbd_information19;
  End If;
  If (p_rec.tbd_information20 = hr_api.g_varchar2) then
    p_rec.tbd_information20 := g_old_rec.tbd_information20;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  VALIDITY_CHECK (
        P_REC                                => P_REC);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  if (    (TFL_LINES (P_REC.BOOKING_DEAL_ID))
      and (    (P_REC.PRICE_LIST_ID	     <>	G_OLD_REC.PRICE_LIST_ID      )
           or  (P_REC.EVENT_ID		     <>	G_OLD_REC.EVENT_ID           )
           or  (P_REC.ACTIVITY_VERSION_ID    <>	G_OLD_REC.ACTIVITY_VERSION_ID)
           or  (P_REC.CATEGORY		     <>	G_OLD_REC.CATEGORY   ))) then
    CONSTRAINT_ERROR ('NON-TRANSFERABLE BASIS');
  end if;
  --
  -- Check if dates invalidate any enrollments
  --
  if p_rec.start_date <> g_old_rec.start_date or
     p_rec.end_date   <> g_old_rec.end_date then
     --
     check_dates_conflict(p_rec.booking_deal_id,
	      	          p_rec.start_date,
		          p_rec.end_date);
     --
  end if;
  --
  VALIDITY_CHECK (
        P_REC                                => P_REC);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if (TFL_LINES (
        P_BOOKING_DEAL_ID                    => P_REC.BOOKING_DEAL_ID)) then
    CONSTRAINT_ERROR ('OTA_TBD_FINANCE_LINES');
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_tbd;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  insert_validate(p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_tbd;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_booking_deal_id              out nocopy number,
  p_customer_id                  in number           default null,
  p_approved_by_person_id        in number           default null,
  p_business_group_id            in number,
  p_name                         in varchar2,
  p_object_version_number        out nocopy number,
  p_start_date                   in date,
  p_category                     in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_description                  in varchar2         default null,
  p_discount_percentage          in number           default null,
  p_end_date                     in date             default null,
  p_number_of_places             in number           default null,
  P_LIMIT_EACH_EVENT_FLAG        in varchar2         default null,
  p_overdraft_limit              in number           default null,
  p_type                         in varchar2         default null,
  p_price_list_id                in number           default null,
  p_activity_version_id          in number           default null,
  p_event_id                     in number           default null,
  p_tbd_information_category     in varchar2         default null,
  p_tbd_information1             in varchar2         default null,
  p_tbd_information2             in varchar2         default null,
  p_tbd_information3             in varchar2         default null,
  p_tbd_information4             in varchar2         default null,
  p_tbd_information5             in varchar2         default null,
  p_tbd_information6             in varchar2         default null,
  p_tbd_information7             in varchar2         default null,
  p_tbd_information8             in varchar2         default null,
  p_tbd_information9             in varchar2         default null,
  p_tbd_information10            in varchar2         default null,
  p_tbd_information11            in varchar2         default null,
  p_tbd_information12            in varchar2         default null,
  p_tbd_information13            in varchar2         default null,
  p_tbd_information14            in varchar2         default null,
  p_tbd_information15            in varchar2         default null,
  p_tbd_information16            in varchar2         default null,
  p_tbd_information17            in varchar2         default null,
  p_tbd_information18            in varchar2         default null,
  p_tbd_information19            in varchar2         default null,
  p_tbd_information20            in varchar2         default null,
  p_validate                     in boolean   default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  convert_args
  (
  null,
  p_customer_id,
  p_approved_by_person_id,
  p_business_group_id,
  p_name,
  null,
  p_start_date,
  p_category,
  p_comments,
  p_description,
  p_discount_percentage,
  p_end_date,
  p_number_of_places,
  P_LIMIT_EACH_EVENT_FLAG,
  p_overdraft_limit,
  p_type,
  p_price_list_id,
  p_activity_version_id,
  p_event_id,
  p_tbd_information_category,
  p_tbd_information1,
  p_tbd_information2,
  p_tbd_information3,
  p_tbd_information4,
  p_tbd_information5,
  p_tbd_information6,
  p_tbd_information7,
  p_tbd_information8,
  p_tbd_information9,
  p_tbd_information10,
  p_tbd_information11,
  p_tbd_information12,
  p_tbd_information13,
  p_tbd_information14,
  p_tbd_information15,
  p_tbd_information16,
  p_tbd_information17,
  p_tbd_information18,
  p_tbd_information19,
  p_tbd_information20
  );
  --
  -- Having converted the arguments into the tbd_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_booking_deal_id := l_rec.booking_deal_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_tbd;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  lck
	(
	p_rec.booking_deal_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  update_validate(convert_defs(p_rec));
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_tbd;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_booking_deal_id              in number,
  p_customer_id                  in number           default hr_api.g_number,
  p_approved_by_person_id        in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_start_date                   in date             default hr_api.g_date,
  p_category                     in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_discount_percentage          in number           default hr_api.g_number,
  p_end_date                     in date             default hr_api.g_date,
  p_number_of_places             in number           default hr_api.g_number,
  P_LIMIT_EACH_EVENT_FLAG        in varchar2         default HR_API.G_VARCHAR2,
  p_overdraft_limit              in number           default hr_api.g_number,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_price_list_id                in number           default hr_api.g_number,
  p_activity_version_id          in number           default hr_api.g_number,
  p_event_id                     in number           default hr_api.g_number,
  p_tbd_information_category     in varchar2         default hr_api.g_varchar2,
  p_tbd_information1             in varchar2         default hr_api.g_varchar2,
  p_tbd_information2             in varchar2         default hr_api.g_varchar2,
  p_tbd_information3             in varchar2         default hr_api.g_varchar2,
  p_tbd_information4             in varchar2         default hr_api.g_varchar2,
  p_tbd_information5             in varchar2         default hr_api.g_varchar2,
  p_tbd_information6             in varchar2         default hr_api.g_varchar2,
  p_tbd_information7             in varchar2         default hr_api.g_varchar2,
  p_tbd_information8             in varchar2         default hr_api.g_varchar2,
  p_tbd_information9             in varchar2         default hr_api.g_varchar2,
  p_tbd_information10            in varchar2         default hr_api.g_varchar2,
  p_tbd_information11            in varchar2         default hr_api.g_varchar2,
  p_tbd_information12            in varchar2         default hr_api.g_varchar2,
  p_tbd_information13            in varchar2         default hr_api.g_varchar2,
  p_tbd_information14            in varchar2         default hr_api.g_varchar2,
  p_tbd_information15            in varchar2         default hr_api.g_varchar2,
  p_tbd_information16            in varchar2         default hr_api.g_varchar2,
  p_tbd_information17            in varchar2         default hr_api.g_varchar2,
  p_tbd_information18            in varchar2         default hr_api.g_varchar2,
  p_tbd_information19            in varchar2         default hr_api.g_varchar2,
  p_tbd_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  convert_args
  (
  p_booking_deal_id,
  p_customer_id,
  p_approved_by_person_id,
  p_business_group_id,
  p_name,
  p_object_version_number,
  p_start_date,
  p_category,
  p_comments,
  p_description,
  p_discount_percentage,
  p_end_date,
  p_number_of_places,
  P_LIMIT_EACH_EVENT_FLAG,
  p_overdraft_limit,
  p_type,
  p_price_list_id,
  p_activity_version_id,
  p_event_id,
  p_tbd_information_category,
  p_tbd_information1,
  p_tbd_information2,
  p_tbd_information3,
  p_tbd_information4,
  p_tbd_information5,
  p_tbd_information6,
  p_tbd_information7,
  p_tbd_information8,
  p_tbd_information9,
  p_tbd_information10,
  p_tbd_information11,
  p_tbd_information12,
  p_tbd_information13,
  p_tbd_information14,
  p_tbd_information15,
  p_tbd_information16,
  p_tbd_information17,
  p_tbd_information18,
  p_tbd_information19,
  p_tbd_information20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	in g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_tbd;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  lck
	(
	p_rec.booking_deal_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_tbd;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_booking_deal_id                    in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.booking_deal_id:= p_booking_deal_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the tbd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end OTA_TBD_API;

/
