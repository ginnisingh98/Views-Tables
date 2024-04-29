--------------------------------------------------------
--  DDL for Package Body OTA_BST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BST_API" as
/* $Header: otbst01t.pkb 120.2 2005/07/21 19:01:44 dhmulia noship $ */
--
-- Private package current record structure definition
--
g_old_rec		g_rec_type;
--
-- Global package name
--
G_PACKAGE		varchar2(33)	:= '  OTA_BST_API.';
--
-- Global api dml status
--
g_api_dml		boolean;
--
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_booking_status_type_id_i  number   default null;
--
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_booking_status_type_id      number         default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  W_PROC 	varchar2(72) := G_PACKAGE||'return_api_dml_status';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
--   P_CONSTRAINT_NAME is in upper format and is just the constraint name
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
procedure CONSTRAINT_ERROR (
	P_CONSTRAINT_NAME	     in ALL_CONSTRAINTS.CONSTRAINT_NAME%type
	) is
--
	W_PROC				varchar2 (72)
		:= G_PACKAGE || 'CONSTRAINT_ERROR';
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Key constraints
	--
	if (P_CONSTRAINT_NAME = 'OTA_BOOKING_STATUS_TYPES_FK1') Then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13202_GEN_INVALID_KEY');
		FND_MESSAGE.SET_TOKEN ('COLUMN_NAME', 'ORGANIZATION_ID');
		FND_MESSAGE.SET_TOKEN ('TABLE_NAME',  'HR_ORGANIZATION_UNITS');
--	elsif (P_CONSTRAINT_NAME = 'OTA_BOOKING_STATUS_TYPES_PK') Then
-- Unkn constraint will be raised giving constraint name.
--		FND_MESSAGE.SET_NAME ('OTA', 'HR_6153_ALW_PROCEDURE_FAIL');
--		FND_MESSAGE.SET_TOKEN ('PROCEDURE', W_PROC);
--		FND_MESSAGE.SET_TOKEN ('STEP','10');
	elsif (P_CONSTRAINT_NAME = 'OTA_BOOKING_STATUS_TYPES_UK2') Then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13209_GEN_NOT_UNIQUE');
		FND_MESSAGE.SET_TOKEN ('FIELD',             'The status name');
		FND_MESSAGE.SET_TOKEN ('MESSAGE_EXTENSION', 'Must be unique');
	--
	--	Check constraints
	--
	elsif (P_CONSTRAINT_NAME = 'OTA_BST_ACTIVE_FLAG_CHK') Then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13387_BST_ACTIVE_FLAG_CHK');
	elsif (P_CONSTRAINT_NAME = 'OTA_BST_DEFAULT_FLAG_CHK') Then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13388_BST_DEFAULT_FLAG_CHK');
	elsif (P_CONSTRAINT_NAME = 'OTA_BST_TYPE_CHK') Then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13389_BST_TYPE_CHK');
	--
	--	Other errors, see below
	--
	elsif (P_CONSTRAINT_NAME = 'OTA_BST_DUPLICATE_NAME') then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13209_GEN_NOT_UNIQUE');
		FND_MESSAGE.SET_TOKEN ('FIELD',             'Name');
		FND_MESSAGE.SET_TOKEN ('MESSAGE_EXTENSION', 'Must be unique');
	elsif (P_CONSTRAINT_NAME = 'OTA_BST_BSH_EXISTS') then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_443818_NO_DEL_HAS_CHILD');
		FND_MESSAGE.SET_TOKEN ('ENTITY_NAME', 'Booking status history');
	elsif (P_CONSTRAINT_NAME = 'OTA_BST_TDB_EXISTS') then
                FND_MESSAGE.SET_NAME ('OTA', 'OTA_443818_NO_DEL_HAS_CHILD');
		FND_MESSAGE.SET_TOKEN ('ENTITY_NAME', 'Delegate booking');
	elsif p_constraint_name = 'OTA_BST_ACTIVE_DEFAULT' then
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13390_BST_ACTIVE_DEFAULT');
        elsif p_constraint_name = 'OTA_BST_DUPLICATE_DEFAULT' then
                FND_MESSAGE.SET_NAME ('OTA', 'OTA_13391_BST_DUPLICATE_DEFAUL');
	--
	--	Unknown !
	--
	else
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13259_GEN_UNKN_CONSTRAINT');
		FND_MESSAGE.SET_TOKEN ('PROCEDURE',  W_PROC);
		FND_MESSAGE.SET_TOKEN ('CONSTRAINT', P_CONSTRAINT_NAME);
	end if;
	FND_MESSAGE.RAISE_ERROR;
	--
	HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
	--
end CONSTRAINT_ERROR;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< GET_BOOKING_STATUS_TYPE_ID >---------------
-- ----------------------------------------------------------------------------
--
--      Retrieve the Booking Status Type ID using the NAME and
--      BUSINESS_GROUP_ID.
--
function GET_BOOKING_STATUS_TYPE_ID (
        P_BUSINESS_GROUP_ID                  in number,
        P_NAME                               in varchar2
        ) return number is
  --
  W_PROCEDURE                                   varchar2 (72)
        := G_PACKAGE || 'GET_BOOKING_STATUS_TYPE_ID';
  --
  W_BOOKING_STATUS_TYPE_ID                      number (9);
  --
  cursor C1 is
    select BST.BOOKING_STATUS_TYPE_ID
      from OTA_BOOKING_STATUS_TYPES_VL          BST
      where BST.BUSINESS_GROUP_ID             = P_BUSINESS_GROUP_ID
        and BST.NAME                          = P_NAME;
  --
begin
  --
  HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
  --
  open C1;
  fetch C1
    into W_BOOKING_STATUS_TYPE_ID;
  if (C1%notfound) then
    CONSTRAINT_ERROR ('OTA_BST_UNKNOWN');
  end if;
  close C1;
  --
  HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
  --
  return (W_BOOKING_STATUS_TYPE_ID);
  --
end;
--
-- ----------------------------------------------------------------------------
-- ----------------------< GET_BOOKING_STATUS_TYPE_ID >---------------------------
-- ----------------------------------------------------------------------------
--
--	Returns the booking status NAME corresponding
--	to P_BOOKING_STATUS_TYPE_ID.
--
function GET_BOOKING_STATUS_TYPE (
	P_BOOKING_STATUS_TYPE_ID	     in	number
	) return varchar2 is
--
cursor C1 is
	select BST.NAME
 	  from OTA_BOOKING_STATUS_TYPES_TL		BST
	  where BST.BOOKING_STATUS_TYPE_ID    = P_BOOKING_STATUS_TYPE_ID
            and BST.LANGUAGE = USERENV('LANG');
--
W_PROCEDURE					varchar2 (72)
	:= G_PACKAGE || 'GET_BOOKING_STATUS_TYPE';
W_NAME						varchar2 (80);
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	open C1;
	fetch C1
	  into W_NAME;
	if (C1%notfound) then
		CONSTRAINT_ERROR ('OTA_BST_UNKNOWN');
	end if;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
	return (W_NAME);
	--
end GET_BOOKING_STATUS_TYPE;
--
-- ----------------------------------------------------------------------------
-- ---------------------< DEFAULT_BOOKING_STATUS_TYPE >------------------------
-- ----------------------------------------------------------------------------
--
--      Takes business group and booking status type and retrieves default
--      booking status type id and name.
--
procedure DEFAULT_BOOKING_STATUS_TYPE (
        P_BUSINESS_GROUP_ID                  in number,
        P_TYPE                               in varchar2,
        P_EVENT_STATUS                       in varchar2,
        P_BOOKING_STATUS_TYPE_ID            out nocopy number,
        P_NAME                              out nocopy varchar2
        ) is
  --
  W_PROCEDURE                           varchar2 (72)
        := G_PACKAGE || 'DEFAULT_BOOKING_STATUS_TYPE';
  --
  cursor C_DEFAULT is
    select BST.BOOKING_STATUS_TYPE_ID,
           BST.NAME
      from OTA_BOOKING_STATUS_TYPES_VL     BST
      where BST.BUSINESS_GROUP_ID   = P_BUSINESS_GROUP_ID
      and BST.DEFAULT_FLAG          = 'Y'
      and BST.TYPE                 <> 'C'
      and ((P_EVENT_STATUS = 'F' AND    --  Bug #1870097.  For status 'F' use Waitlist as default, for status 'P' use either Waitlisted or Requested
            BST.TYPE = 'W')
           or (P_EVENT_STATUS = 'P' AND
               BST.TYPE IN ('R', 'W'))
           or P_EVENT_STATUS NOT IN ('F', 'P'))
      order by BST.TYPE;
  --
begin
  --
  HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
  --
  open C_DEFAULT;
  fetch C_DEFAULT
  into P_BOOKING_STATUS_TYPE_ID,
       P_NAME;
  close C_DEFAULT;
  --
  HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
  --
end DEFAULT_BOOKING_STATUS_TYPE;
--
-- ----------------------------------------------------------------------------
-- --------------------------< CHECK_UNIQUE_NAME >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Check that a business status type name is unique within the
--      business group.
--
procedure CHECK_UNIQUE_NAME (
        P_BUSINESS_GROUP_ID                  in number,
        P_NAME                               in varchar2,
        P_BOOKING_STATUS_TYPE_ID             in number
        ) is
--
	W_PROCEDURE				varchar2 (72)
		:= G_PACKAGE || 'CHECK_UNIQUE_NAME';
	--
	V_UNIQUE				varchar (3);
	--
	cursor C_UNIQUE is
		select 'NO'
		  from OTA_BOOKING_STATUS_TYPES_VL BST
		  where BST.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
		    and upper (BST.NAME)      =	upper (P_NAME)
		    and (    (P_BOOKING_STATUS_TYPE_ID
					     is null)
		         or  (BST.BOOKING_STATUS_TYPE_ID
					     <> P_BOOKING_STATUS_TYPE_ID));
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	open C_UNIQUE;
	fetch C_UNIQUE
	  into V_UNIQUE;
	if(C_UNIQUE%notfound) then
		V_UNIQUE := 'YES';
	end if;
	close C_UNIQUE;
	--

	if (V_UNIQUE <> 'YES') then
		CONSTRAINT_ERROR ('OTA_BOOKING_STATUS_TYPES_UK2');
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_UNIQUE_NAME;
--
-- ----------------------------------------------------------------------------
-- -------------------------< CHECK_SINGLE_DEFAULT >---------------------------
-- ----------------------------------------------------------------------------
--
--      Checks that within P_BUSINESS_GROUP_ID there will only be one default
--      status type for P_TYPE, including P_NAME, P_DEFAULT_FLAG.
--
procedure CHECK_SINGLE_DEFAULT (
        P_BUSINESS_GROUP_ID                  in number,
        P_TYPE                               in varchar2,
        P_NAME                               in varchar2
        ) is
  --
  W_PROCEDURE                                   varchar2 (72)
        := G_PACKAGE || 'CHECK_SINGLE_DEFAULT';
  L_NAME VARCHAR2(80);

--
  cursor C_DEFAULT is
    select BST.NAME
      from OTA_BOOKING_STATUS_TYPES_VL     BST
      where BST.BUSINESS_GROUP_ID   = P_BUSINESS_GROUP_ID
      and BST.TYPE                  = P_TYPE
      and BST.DEFAULT_FLAG          = 'Y';
--
begin
  --
  HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
  --
  open C_DEFAULT;
  fetch C_DEFAULT into L_NAME;
  close C_DEFAULT;
  --

  if l_name is not null and l_name <> p_name then
    CONSTRAINT_ERROR ('OTA_BST_DUPLICATE_DEFAULT');
  end if;

  HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
  --
end CHECK_SINGLE_DEFAULT;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< VALIDITY_CHECK >---------------------------
-- ----------------------------------------------------------------------------
--
procedure VALIDITY_CHECK (
        P_REC                                in G_REC_TYPE
        ) is
  --
  W_PROCEDURE                                   varchar2 (72)
        := G_PACKAGE || 'VALIDITY_CHECK';

  --
begin
  --
  HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
  --
 CHECK_UNIQUE_NAME (
        P_BUSINESS_GROUP_ID                  => P_REC.BUSINESS_GROUP_ID,
        P_NAME                               => P_REC.NAME,
        P_BOOKING_STATUS_TYPE_ID             => P_REC.BOOKING_STATUS_TYPE_ID);
  --
  if P_REC.DEFAULT_FLAG = 'Y' AND
     P_REC.ACTIVE_FLAG <> 'Y' then
    CONSTRAINT_ERROR ('OTA_BST_ACTIVE_DEFAULT');
  end if;

/* Bug 1634112  only call check_single_default if default_flag='Y'*/
IF P_REC.DEFAULT_FLAG ='Y' THEN
   IF (((p_rec.booking_Status_type_id is not null) and
      nvl(g_old_rec.default_flag,hr_api.g_varchar2) <>
         nvl(p_rec.default_flag,hr_api.g_varchar2))
   or (p_rec.booking_status_type_id is null)) then
    CHECK_SINGLE_DEFAULT (
        P_BUSINESS_GROUP_ID                  => P_REC.BUSINESS_GROUP_ID,
        P_TYPE                               => P_REC.TYPE,
        P_NAME                               => P_REC.NAME);
   END IF;
END IF;
  --
  HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
  --
end VALIDITY_CHECK;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_BSH_EXISTS >-------------------------
-- ----------------------------------------------------------------------------
--
--      Delete not allowed if any OTA_BOOKING_STATUS_HISTORIES rows exist
--      for this BOOKING_STATUS_TYPE_ID.
--
procedure CHECK_BSH_EXISTS (
        P_BOOKING_STATUS_TYPE_ID             in number
        ) is
--
	W_PROCEDURE				varchar2 (72)
		:= G_PACKAGE || 'CHECK_BSH_EXISTS';
	--
	W_OK					varchar2 (3);
	--
	cursor C1 is
		select 'NO'
		  from OTA_BOOKING_STATUS_HISTORIES
						BSH
		  where BSH.BOOKING_STATUS_TYPE_ID
					      = P_BOOKING_STATUS_TYPE_ID;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	--	Any history ?
	--
	open C1;
	fetch C1
	  into W_OK;
	if (C1%found) then
		close C1;
		CONSTRAINT_ERROR ('OTA_BST_BSH_EXISTS');
	end if;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_BSH_EXISTS;
--
-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_TDB_EXISTS >-------------------------
-- ----------------------------------------------------------------------------
--
--      Delete not allowed if any OTA_TRANING_DELEGATES rows exist for
--      this BOOKING_STATUS_TYPE_ID.
--
procedure CHECK_TDB_EXISTS (
        P_BOOKING_STATUS_TYPE_ID             in number
        ) is
--
	W_PROCEDURE                             varchar2 (72)
        	:= G_PACKAGE || 'CHECK_TDB_EXISTS';
	--
	W_OK					varchar2 (3);
	--
	cursor C1 is
		select 'NO'
		  from OTA_DELEGATE_BOOKINGS	TDB
		  where TDB.BOOKING_STATUS_TYPE_ID
					      = P_BOOKING_STATUS_TYPE_ID;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	open C1;
	fetch C1
	  into W_OK;
	if (C1%found) then
		close C1;
		CONSTRAINT_ERROR ('OTA_BST_TDB_EXISTS');
	end if;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_TDB_EXISTS;

-- ----------------------------------------------------------------------------
-- -------------------------------< CHECK_BSE_EXISTS >-------------------------
-- ----------------------------------------------------------------------------
--
--      Delete not allowed if any OTA_BOOKING_STATUS_EXCL rows exist for
--      this BOOKING_STATUS_TYPE_ID.
--
procedure CHECK_BSE_EXISTS (
        P_BOOKING_STATUS_TYPE_ID             in number
        ) is
--
	W_PROCEDURE                             varchar2 (72)
        	:= G_PACKAGE || 'CHECK_BSE_EXISTS';
	--
	W_OK					varchar2 (3);
	--
	cursor C1 is
		select 'NO'
		  from OTA_BOOKING_STATUS_EXCL	BSE
		  where BSE.BOOKING_STATUS_TYPE_ID
					      = P_BOOKING_STATUS_TYPE_ID;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	open C1;
	fetch C1
	  into W_OK;
	if (C1%found) then
		close C1;
		fnd_message.set_name('OTA','OTA_443877_BST_DELETE_CHK');
        fnd_message.raise_error;
	end if;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_BSE_EXISTS;
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
  p_booking_status_type_id             in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		booking_status_type_id,
	business_group_id,
	active_flag,
	default_flag,
	name,
	object_version_number,
	type,
	comments,
	description,
	bst_information_category,
	bst_information1,
	bst_information2,
	bst_information3,
	bst_information4,
	bst_information5,
	bst_information6,
	bst_information7,
	bst_information8,
	bst_information9,
	bst_information10,
	bst_information11,
	bst_information12,
	bst_information13,
	bst_information14,
	bst_information15,
	bst_information16,
	bst_information17,
	bst_information18,
	bst_information19,
	bst_information20
    from	ota_booking_status_types_vl
    where	booking_status_type_id = p_booking_status_type_id;
--
  W_PROC	varchar2(72)	:= G_PACKAGE||'g_old_rec_current';
  l_fct_ret	boolean;
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  If (
	p_booking_status_type_id is null or
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_booking_status_type_id = g_old_rec.booking_status_type_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      HR_UTILITY.SET_LOCATION(W_PROC, 10);
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
        FND_MESSAGE.SET_NAME('OTA', 'HR_7220_INVALID_PRIMARY_KEY');
        HR_UTILITY.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        FND_MESSAGE.SET_NAME('OTA', 'HR_7155_OBJECT_INVALID');
        HR_UTILITY.raise_error;
      End If;
      HR_UTILITY.SET_LOCATION(W_PROC, 15);
      l_fct_ret := true;
    End If;
  End If;
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 20);
  Return (l_fct_ret);
--
End g_old_rec_current;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_booking_status_type_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_booking_status_types bst
     where bst.booking_status_type_id = p_booking_status_type_id
       and pbg.business_group_id = bst.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'booking_status_type_id'
    ,p_argument_value     => p_booking_status_type_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'BOOKING_STATUS_TYPE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_booking_status_type_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_booking_status_types bst
     where bst.booking_status_type_id = p_booking_status_type_id
       and pbg.business_group_id = bst.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'booking_status_type_id'
    ,p_argument_value     => p_booking_status_type_id
    );
  --
  if ( nvl(ota_bst_api.g_booking_status_type_id, hr_api.g_number)
       = p_booking_status_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_bst_api.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    ota_bst_api.g_booking_status_type_id      := p_booking_status_type_id;
    ota_bst_api.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--

--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_booking_status_type_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_bst_api.g_booking_status_type_id_i := p_booking_status_type_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
  W_PROC	varchar2(72) := G_PACKAGE||'insert_dml';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_booking_status_types
  --
  insert into ota_booking_status_types
  (	booking_status_type_id,
	business_group_id,
	active_flag,
	default_flag,
	name,
	object_version_number,
	type,
	comments,
	description,
	bst_information_category,
	bst_information1,
	bst_information2,
	bst_information3,
	bst_information4,
	bst_information5,
	bst_information6,
	bst_information7,
	bst_information8,
	bst_information9,
	bst_information10,
	bst_information11,
	bst_information12,
	bst_information13,
	bst_information14,
	bst_information15,
	bst_information16,
	bst_information17,
	bst_information18,
	bst_information19,
	bst_information20
  )
  Values
  (	p_rec.booking_status_type_id,
	p_rec.business_group_id,
	p_rec.active_flag,
	p_rec.default_flag,
	p_rec.name,
	p_rec.object_version_number,
	p_rec.type,
	p_rec.comments,
	p_rec.description,
	p_rec.bst_information_category,
	p_rec.bst_information1,
	p_rec.bst_information2,
	p_rec.bst_information3,
	p_rec.bst_information4,
	p_rec.bst_information5,
	p_rec.bst_information6,
	p_rec.bst_information7,
	p_rec.bst_information8,
	p_rec.bst_information9,
	p_rec.bst_information10,
	p_rec.bst_information11,
	p_rec.bst_information12,
	p_rec.bst_information13,
	p_rec.bst_information14,
	p_rec.bst_information15,
	p_rec.bst_information16,
	p_rec.bst_information17,
	p_rec.bst_information18,
	p_rec.bst_information19,
	p_rec.bst_information20
  );
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (P_CONSTRAINT_NAME => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (P_CONSTRAINT_NAME => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (P_CONSTRAINT_NAME => hr_api.strip_constraint_name(SQLERRM));
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
  W_PROC	varchar2(72) := G_PACKAGE||'update_dml';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_booking_status_types Row
  --
  update ota_booking_status_types
  set
  booking_status_type_id            = p_rec.booking_status_type_id,
  business_group_id                 = p_rec.business_group_id,
  active_flag                       = p_rec.active_flag,
  default_flag                      = p_rec.default_flag,
  name                              = p_rec.name,
  object_version_number             = p_rec.object_version_number,
  type                              = p_rec.type,
  comments                          = p_rec.comments,
  description                       = p_rec.description,
  bst_information_category          = p_rec.bst_information_category,
  bst_information1                  = p_rec.bst_information1,
  bst_information2                  = p_rec.bst_information2,
  bst_information3                  = p_rec.bst_information3,
  bst_information4                  = p_rec.bst_information4,
  bst_information5                  = p_rec.bst_information5,
  bst_information6                  = p_rec.bst_information6,
  bst_information7                  = p_rec.bst_information7,
  bst_information8                  = p_rec.bst_information8,
  bst_information9                  = p_rec.bst_information9,
  bst_information10                 = p_rec.bst_information10,
  bst_information11                 = p_rec.bst_information11,
  bst_information12                 = p_rec.bst_information12,
  bst_information13                 = p_rec.bst_information13,
  bst_information14                 = p_rec.bst_information14,
  bst_information15                 = p_rec.bst_information15,
  bst_information16                 = p_rec.bst_information16,
  bst_information17                 = p_rec.bst_information17,
  bst_information18                 = p_rec.bst_information18,
  bst_information19                 = p_rec.bst_information19,
  bst_information20                 = p_rec.bst_information20
  where booking_status_type_id = p_rec.booking_status_type_id;
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (P_CONSTRAINT_NAME => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (P_CONSTRAINT_NAME => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (P_CONSTRAINT_NAME => hr_api.strip_constraint_name(SQLERRM));
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
  W_PROC	varchar2(72) := G_PACKAGE||'delete_dml';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ota_booking_status_types row.
  --
  delete from ota_booking_status_types
  where booking_status_type_id = p_rec.booking_status_type_id;
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (P_CONSTRAINT_NAME => hr_api.strip_constraint_name(SQLERRM));
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
  W_PROC	varchar2(72) := G_PACKAGE||'pre_insert';
--
  Cursor C_Sel1 is select ota_booking_status_types_s.nextval from sys.dual;
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.booking_status_type_id;
  Close C_Sel1;
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	varchar2(72) := G_PACKAGE||'pre_update';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	varchar2(72) := G_PACKAGE||'pre_delete';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	varchar2(72) := G_PACKAGE||'post_insert';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	varchar2(72) := G_PACKAGE||'post_update';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	varchar2(72) := G_PACKAGE||'post_delete';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_booking_status_type_id             in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	booking_status_type_id,
	business_group_id,
	active_flag,
	default_flag,
	name,
	object_version_number,
	type,
	comments,
	description,
	bst_information_category,
	bst_information1,
	bst_information2,
	bst_information3,
	bst_information4,
	bst_information5,
	bst_information6,
	bst_information7,
	bst_information8,
	bst_information9,
	bst_information10,
	bst_information11,
	bst_information12,
	bst_information13,
	bst_information14,
	bst_information15,
	bst_information16,
	bst_information17,
	bst_information18,
	bst_information19,
	bst_information20
    from	ota_booking_status_types
    where	booking_status_type_id = p_booking_status_type_id
    for	update nowait;
--
  W_PROC	varchar2(72) := G_PACKAGE||'lck';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => W_PROC,
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
    FND_MESSAGE.SET_NAME('OTA', 'HR_7220_INVALID_PRIMARY_KEY');
    HR_UTILITY.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        FND_MESSAGE.SET_NAME('OTA', 'HR_7155_OBJECT_INVALID');
        HR_UTILITY.raise_error;
      End If;
--
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    FND_MESSAGE.SET_NAME('OTA', 'HR_7165_OBJECT_LOCKED');
    FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'ota_booking_status_types');
    HR_UTILITY.raise_error;
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
	p_booking_status_type_id        in number,
	p_business_group_id             in number,
	p_active_flag                   in varchar2,
	p_default_flag                  in varchar2,
	p_name                          in varchar2,
	p_object_version_number         in number,
	p_type                          in varchar2,
	p_comments                      in varchar2,
	p_description                   in varchar2,
	p_bst_information_category      in varchar2,
	p_bst_information1              in varchar2,
	p_bst_information2              in varchar2,
	p_bst_information3              in varchar2,
	p_bst_information4              in varchar2,
	p_bst_information5              in varchar2,
	p_bst_information6              in varchar2,
	p_bst_information7              in varchar2,
	p_bst_information8              in varchar2,
	p_bst_information9              in varchar2,
	p_bst_information10             in varchar2,
	p_bst_information11             in varchar2,
	p_bst_information12             in varchar2,
	p_bst_information13             in varchar2,
	p_bst_information14             in varchar2,
	p_bst_information15             in varchar2,
	p_bst_information16             in varchar2,
	p_bst_information17             in varchar2,
	p_bst_information18             in varchar2,
	p_bst_information19             in varchar2,
	p_bst_information20             in varchar2
	)
	Return g_rec_type is
--
  l_rec	g_rec_type;
  W_PROC  varchar2(72) := G_PACKAGE||'convert_args';
--
Begin
  --
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.booking_status_type_id           := p_booking_status_type_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.active_flag                      := p_active_flag;
  l_rec.default_flag                     := p_default_flag;
  l_rec.name                             := p_name;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.type                             := p_type;
  l_rec.comments                         := p_comments;
  l_rec.description                      := p_description;
  l_rec.bst_information_category         := p_bst_information_category;
  l_rec.bst_information1                 := p_bst_information1;
  l_rec.bst_information2                 := p_bst_information2;
  l_rec.bst_information3                 := p_bst_information3;
  l_rec.bst_information4                 := p_bst_information4;
  l_rec.bst_information5                 := p_bst_information5;
  l_rec.bst_information6                 := p_bst_information6;
  l_rec.bst_information7                 := p_bst_information7;
  l_rec.bst_information8                 := p_bst_information8;
  l_rec.bst_information9                 := p_bst_information9;
  l_rec.bst_information10                := p_bst_information10;
  l_rec.bst_information11                := p_bst_information11;
  l_rec.bst_information12                := p_bst_information12;
  l_rec.bst_information13                := p_bst_information13;
  l_rec.bst_information14                := p_bst_information14;
  l_rec.bst_information15                := p_bst_information15;
  l_rec.bst_information16                := p_bst_information16;
  l_rec.bst_information17                := p_bst_information17;
  l_rec.bst_information18                := p_bst_information18;
  l_rec.bst_information19                := p_bst_information19;
  l_rec.bst_information20                := p_bst_information20;
  --
  -- Return the plsql record structure.
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	  varchar2(72) := G_PACKAGE||'convert_defs';
--
Begin
  --
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id := g_old_rec.business_group_id;
  End If;
  If (p_rec.active_flag = hr_api.g_varchar2) then
    p_rec.active_flag := g_old_rec.active_flag;
  End If;
  If (p_rec.default_flag = hr_api.g_varchar2) then
    p_rec.default_flag := g_old_rec.default_flag;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name := g_old_rec.name;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type := g_old_rec.type;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments := g_old_rec.comments;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description := g_old_rec.description;
  End If;
  If (p_rec.bst_information_category = hr_api.g_varchar2) then
    p_rec.bst_information_category := g_old_rec.bst_information_category;
  End If;
  If (p_rec.bst_information1 = hr_api.g_varchar2) then
    p_rec.bst_information1 := g_old_rec.bst_information1;
  End If;
  If (p_rec.bst_information2 = hr_api.g_varchar2) then
    p_rec.bst_information2 := g_old_rec.bst_information2;
  End If;
  If (p_rec.bst_information3 = hr_api.g_varchar2) then
    p_rec.bst_information3 := g_old_rec.bst_information3;
  End If;
  If (p_rec.bst_information4 = hr_api.g_varchar2) then
    p_rec.bst_information4 := g_old_rec.bst_information4;
  End If;
  If (p_rec.bst_information5 = hr_api.g_varchar2) then
    p_rec.bst_information5 := g_old_rec.bst_information5;
  End If;
  If (p_rec.bst_information6 = hr_api.g_varchar2) then
    p_rec.bst_information6 := g_old_rec.bst_information6;
  End If;
  If (p_rec.bst_information7 = hr_api.g_varchar2) then
    p_rec.bst_information7 := g_old_rec.bst_information7;
  End If;
  If (p_rec.bst_information8 = hr_api.g_varchar2) then
    p_rec.bst_information8 := g_old_rec.bst_information8;
  End If;
  If (p_rec.bst_information9 = hr_api.g_varchar2) then
    p_rec.bst_information9 := g_old_rec.bst_information9;
  End If;
  If (p_rec.bst_information10 = hr_api.g_varchar2) then
    p_rec.bst_information10 := g_old_rec.bst_information10;
  End If;
  If (p_rec.bst_information11 = hr_api.g_varchar2) then
    p_rec.bst_information11 := g_old_rec.bst_information11;
  End If;
  If (p_rec.bst_information12 = hr_api.g_varchar2) then
    p_rec.bst_information12 := g_old_rec.bst_information12;
  End If;
  If (p_rec.bst_information13 = hr_api.g_varchar2) then
    p_rec.bst_information13 := g_old_rec.bst_information13;
  End If;
  If (p_rec.bst_information14 = hr_api.g_varchar2) then
    p_rec.bst_information14 := g_old_rec.bst_information14;
  End If;
  If (p_rec.bst_information15 = hr_api.g_varchar2) then
    p_rec.bst_information15 := g_old_rec.bst_information15;
  End If;
  If (p_rec.bst_information16 = hr_api.g_varchar2) then
    p_rec.bst_information16 := g_old_rec.bst_information16;
  End If;
  If (p_rec.bst_information17 = hr_api.g_varchar2) then
    p_rec.bst_information17 := g_old_rec.bst_information17;
  End If;
  If (p_rec.bst_information18 = hr_api.g_varchar2) then
    p_rec.bst_information18 := g_old_rec.bst_information18;
  End If;
  If (p_rec.bst_information19 = hr_api.g_varchar2) then
    p_rec.bst_information19 := g_old_rec.bst_information19;
  End If;
  If (p_rec.bst_information20 = hr_api.g_varchar2) then
    p_rec.bst_information20 := g_old_rec.bst_information20;
  End If;
  --
  -- Return the plsql record structure.
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	varchar2(72) := G_PACKAGE||'insert_validate';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  VALIDITY_CHECK (
        P_REC                                => P_REC);
  --
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  l_default_flag_changed boolean :=
       ota_general.value_changed(g_old_rec.default_flag,
                                 p_rec.default_flag);
--
  W_PROC	varchar2(72) := G_PACKAGE||'update_validate';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  if l_default_flag_changed then
    VALIDITY_CHECK (
        P_REC                                => P_REC);
  end if;
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
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
  W_PROC	varchar2(72) := G_PACKAGE||'delete_validate';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Call all supporting business operations
  --
  CHECK_BSH_EXISTS (
        P_BOOKING_STATUS_TYPE_ID             =>	P_REC.BOOKING_STATUS_TYPE_ID);
  --
  CHECK_TDB_EXISTS (
        P_BOOKING_STATUS_TYPE_ID             => P_REC.BOOKING_STATUS_TYPE_ID);
  --
  CHECK_BSE_EXISTS (
        P_BOOKING_STATUS_TYPE_ID             => P_REC.BOOKING_STATUS_TYPE_ID);

   --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean
  ) is
--
  W_PROC	varchar2(72) := G_PACKAGE||'ins';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_bst;
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
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_bst;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_booking_status_type_id       out nocopy number,
  p_business_group_id            in number,
  p_active_flag                  in varchar2,
  p_default_flag                 in varchar2,
  p_name                         in varchar2,
  p_object_version_number        out nocopy number,
  p_type                         in varchar2,
  p_comments                     in varchar2         ,
  p_description                  in varchar2         ,
  p_bst_information_category     in varchar2         ,
  p_bst_information1             in varchar2         ,
  p_bst_information2             in varchar2         ,
  p_bst_information3             in varchar2         ,
  p_bst_information4             in varchar2         ,
  p_bst_information5             in varchar2         ,
  p_bst_information6             in varchar2         ,
  p_bst_information7             in varchar2         ,
  p_bst_information8             in varchar2         ,
  p_bst_information9             in varchar2         ,
  p_bst_information10            in varchar2         ,
  p_bst_information11            in varchar2         ,
  p_bst_information12            in varchar2         ,
  p_bst_information13            in varchar2         ,
  p_bst_information14            in varchar2         ,
  p_bst_information15            in varchar2         ,
  p_bst_information16            in varchar2         ,
  p_bst_information17            in varchar2         ,
  p_bst_information18            in varchar2         ,
  p_bst_information19            in varchar2         ,
  p_bst_information20            in varchar2         ,
  p_validate                     in boolean
  ) is
--
  l_rec		g_rec_type;
  W_PROC	varchar2(72) := G_PACKAGE||'ins';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  convert_args
  (
  null,
  p_business_group_id,
  p_active_flag,
  p_default_flag,
  p_name,
  null,
  p_type,
  p_comments,
  p_description,
  p_bst_information_category,
  p_bst_information1,
  p_bst_information2,
  p_bst_information3,
  p_bst_information4,
  p_bst_information5,
  p_bst_information6,
  p_bst_information7,
  p_bst_information8,
  p_bst_information9,
  p_bst_information10,
  p_bst_information11,
  p_bst_information12,
  p_bst_information13,
  p_bst_information14,
  p_bst_information15,
  p_bst_information16,
  p_bst_information17,
  p_bst_information18,
  p_bst_information19,
  p_bst_information20
  );
  --
  -- Having converted the arguments into the bst_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_booking_status_type_id := l_rec.booking_status_type_id;
  p_object_version_number := l_rec.object_version_number;
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean
  ) is
--
  W_PROC	varchar2(72) := G_PACKAGE||'upd';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_bst;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  lck
	(
	p_rec.booking_status_type_id,
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
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_bst;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_booking_status_type_id       in number,
  p_business_group_id            in number           ,
  p_active_flag                  in varchar2         ,
  p_default_flag                 in varchar2         ,
  p_name                         in varchar2         ,
  p_object_version_number        in out nocopy number,
  p_type                         in varchar2         ,
  p_comments                     in varchar2         ,
  p_description                  in varchar2         ,
  p_bst_information_category     in varchar2         ,
  p_bst_information1             in varchar2         ,
  p_bst_information2             in varchar2         ,
  p_bst_information3             in varchar2         ,
  p_bst_information4             in varchar2         ,
  p_bst_information5             in varchar2         ,
  p_bst_information6             in varchar2         ,
  p_bst_information7             in varchar2         ,
  p_bst_information8             in varchar2         ,
  p_bst_information9             in varchar2         ,
  p_bst_information10            in varchar2         ,
  p_bst_information11            in varchar2         ,
  p_bst_information12            in varchar2         ,
  p_bst_information13            in varchar2         ,
  p_bst_information14            in varchar2         ,
  p_bst_information15            in varchar2         ,
  p_bst_information16            in varchar2         ,
  p_bst_information17            in varchar2         ,
  p_bst_information18            in varchar2         ,
  p_bst_information19            in varchar2         ,
  p_bst_information20            in varchar2         ,
  p_validate                     in boolean
  ) is
--
  l_rec		g_rec_type;
  W_PROC	varchar2(72) := G_PACKAGE||'upd';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  convert_args
  (
  p_booking_status_type_id,
  p_business_group_id,
  p_active_flag,
  p_default_flag,
  p_name,
  p_object_version_number,
  p_type,
  p_comments,
  p_description,
  p_bst_information_category,
  p_bst_information1,
  p_bst_information2,
  p_bst_information3,
  p_bst_information4,
  p_bst_information5,
  p_bst_information6,
  p_bst_information7,
  p_bst_information8,
  p_bst_information9,
  p_bst_information10,
  p_bst_information11,
  p_bst_information12,
  p_bst_information13,
  p_bst_information14,
  p_bst_information15,
  p_bst_information16,
  p_bst_information17,
  p_bst_information18,
  p_bst_information19,
  p_bst_information20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	in g_rec_type,
  p_validate   in boolean
  ) is
--
  W_PROC	varchar2(72) := G_PACKAGE||'del';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_bst;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  lck
	(
	p_rec.booking_status_type_id,
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
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_bst;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_booking_status_type_id             in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
--
  l_rec		g_rec_type;
  W_PROC	varchar2(72) := G_PACKAGE||'del';
--
Begin
  HR_UTILITY.SET_LOCATION('Entering:'||W_PROC, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.booking_status_type_id:= p_booking_status_type_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the bst_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  HR_UTILITY.SET_LOCATION(' Leaving:'||W_PROC, 10);
End del;
--
end OTA_BST_API;

/
