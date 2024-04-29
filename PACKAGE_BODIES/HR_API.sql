--------------------------------------------------------
--  DDL for Package Body HR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API" As
/* $Header: hrapiapi.pkb 120.4.12010000.5 2009/03/26 12:32:26 nerao ship $ */
--
-- The following global variable is used by the return_commit_unit function.
--
g_commit_unit_number  number       default 0;
--
-- The following global variable is used by the customer_hooks
-- procedure and call_cus_hooks function.
--
g_call_cus_api_hooks  boolean      default true;
--
-- The following global variable is used by the legislation_hooks
-- procedure and call_leg_hooks function.
--
g_call_leg_api_hooks  boolean      default true;
--
-- The following global variable is used by the application_hooks
-- procedure and call_app_hooks function.
--
g_call_app_api_hooks  boolean      default true;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function and
-- validate_bus_grp_id procedure.
--
g_legislation_code    varchar2(30) default null;
g_business_group_id   number       default null;
--
-- The following two global variables are used
-- to support R12 Initialization procedures.
--
-- 120.2 (START)
--
--g_session_context     number default null;
g_session_context     number default 0;
--
-- 120.2 (END)
--
g_leg_code PER_BUSINESS_GROUPS_PERF.LEGISLATION_CODE%TYPE default null;

-- ------------------------ mandatory_arg_error ------------------------------
--
-- Description: This procedure is called by business processes which have
--              identified a mandatory argument which needs to be NOT null.
--              If the argument is null then need to error.
--              Varchar2 format.
--
Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      varchar2) is
--
Begin
  --
  If (p_argument_value is null) then
    hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
    hr_utility.set_message_token('API_NAME', p_api_name);
    hr_utility.set_message_token('ARGUMENT', p_argument);
    hr_utility.raise_error;
  End If;
  --
End mandatory_arg_error;
--
-- ------------------------ mandatory_arg_error ------------------------------
--
-- Description: Overloaded procedure which converts argument into a varchar2.
--
Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      date) is
--
Begin
  --
  If (p_argument_value is null) then
    hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
    hr_utility.set_message_token('API_NAME', p_api_name);
    hr_utility.set_message_token('ARGUMENT', p_argument);
    hr_utility.raise_error;
  End If;
  --
End mandatory_arg_error;
--
-- ------------------------ mandatory_arg_error ------------------------------
--
-- Description: Overloaded procedure which converts argument into a varchar2.
--
Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      number) is
--
Begin
  --
  If (p_argument_value is null) then
    hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
    hr_utility.set_message_token('API_NAME', p_api_name);
    hr_utility.set_message_token('ARGUMENT', p_argument);
    hr_utility.raise_error;
  End If;
  --
End mandatory_arg_error;

--
-- ----------------------- argument_changed_error ----------------------------
--
-- Description: This procedure is call by business processes which have
--              identified a mandatory argument which has been specified
--              as null and therefore need to error.
--
Procedure argument_changed_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_base_table       in      varchar2 default null) is
--
  l_assoc_column varchar2(70);
--
Begin
  hr_utility.set_message(801, 'HR_7210_API_NON_UPDATEABLE_ARG');
  hr_utility.set_message_token('API_NAME', p_api_name);
  hr_utility.set_message_token('ARGUMENT', p_argument);
  -- hr_utility.raise_error;
  IF p_base_table IS NULL THEN
     l_assoc_column := p_argument;
  ELSE
     l_assoc_column := p_base_table || '.' || p_argument;
  END IF;
  hr_multi_message.add(p_associated_column1 => l_assoc_column);
  --
End argument_changed_error;
--
-- ------------------------------- hr_installed ------------------------------
--
Function HR_Installed Return Boolean Is
  l_pa_installed        fnd_product_installations.status%TYPE;
  l_industry            fnd_product_installations.industry%TYPE;
  l_pa_appid            fnd_product_installations.application_id%TYPE := 800;
Begin
  --
  -- We need to determine if HR is installed.
  --
  If (fnd_installation.get(appl_id     => l_pa_appid,
                           dep_appl_id => l_pa_appid,
                           status      => l_pa_installed,
                           industry    => l_industry)) then
    --
    -- Check to see if the returned status = 'I'
    --
    If (l_pa_installed = 'I') then
      Return (True);
    Else
      Return (False);
    End If;
  Else
    Return (False);
  End If;
End hr_installed;
--
-- ------------------------ return_business_group_id -------------------------
--
Function return_business_group_id
        (p_name	in	per_organization_units.name%TYPE)
         Return per_organization_units.business_group_id%TYPE Is
--
  l_business_group_id  per_organization_units.business_group_id%TYPE;
  l_proc   varchar2(72) := hr_api.g_package||'return_business_group_id';
--
-- Note: This cursor statement should not require a distinct, as
--       business group names should be unique. It has been
--       included to allow use with development databases.
--
  Cursor Sel_Id Is
         select distinct
                business_group_id
           from per_business_groups_perf
          where name = p_name;
--
Begin
  --
  mandatory_arg_error(p_api_name       => l_proc,
                      p_argument       => 'name',
                      p_argument_value => p_name);
  -- DK 2002-11-08 PLSQLSTD
  -- hr_utility.set_location(l_proc, 10);
  --
  -- Select the business group Id
  --
  Open Sel_Id;
    fetch Sel_Id Into l_business_group_id;
    if Sel_Id%notfound then
      Close Sel_Id;
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    end if;
  Close Sel_Id;
  --
  Return (l_business_group_id);
  --
End return_business_group_id;
--
-- ------------------------ return_lookup_code ------------------------------
--
Function return_lookup_code
         (p_meaning	in	fnd_common_lookups.meaning%TYPE default null,
          p_lookup_type in      fnd_common_lookups.lookup_type%TYPE)
         Return fnd_common_lookups.lookup_code%TYPE Is
--
  l_lookup_code  fnd_common_lookups.lookup_code%TYPE := null;
  l_proc         varchar2(72) := hr_api.g_package||'return_lookup_code';
  l_argument     varchar2(30);
--
  Cursor Sel_Id Is
         select  hl.lookup_code
         from    hr_lookups hl
         where   hl.lookup_type     = p_lookup_type
         and     hl.meaning         = p_meaning;
--
Begin
  --
  mandatory_arg_error(p_api_name       => l_proc,
                      p_argument       => 'lookup_type',
                      p_argument_value => p_lookup_type);
  if p_meaning is not null then
    --
    -- DK 2002-11-08 PLSQLSTD
    -- hr_utility.set_location(l_proc, 10);
    --
    -- Select the lookup_code
    --
    open Sel_Id;
    fetch Sel_Id Into l_lookup_code;
    if Sel_Id%notfound then
      close Sel_Id;
      hr_utility.set_message(801, 'HR_7209_API_LOOK_INVALID');
      hr_utility.raise_error;
    end if;
    close Sel_Id;
  end if;
  Return (l_lookup_code);
--
End return_lookup_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_security_group_id
(p_security_group_id             in     number
) is
begin

  --Bug 8250782.Reverting back the fix done for bug6142105 .


 /* fnd_client_info.set_security_group_context
    (context => to_char(p_security_group_id)
    );*/
  --

    if hr_multi_tenancy_pkg.is_multi_tenant_system then
      hr_multi_tenancy_pkg.set_security_group_id
       (p_security_group_id => p_security_group_id);
    else
     -- fnd_global.set_security_group_id_context(p_security_group_id);
     fnd_client_info.set_security_group_context  (context => to_char(p_security_group_id) ); --fix for 8250782
    end if;


  --fix for bug6142105 ends here.
end set_security_group_id;
--
-- ------------------------ validate_bus_grp_id ------------------------------
--
procedure validate_bus_grp_id
         (p_business_group_id in per_business_groups.business_group_id%TYPE
         ,p_associated_column1 in varchar2 default null) is
--
  l_column            varchar2(70);
  l_org_id            number;
  l_security_group_id number;
  l_legislation_code  varchar2(30);
  l_proc              varchar2(72) := hr_api.g_package||'validate_bus_grp_id';
--
  Cursor Sel_Bus Is
    select inf.org_information9
         , inf.org_information14
      from hr_organization_information hoi
         , hr_organization_information inf
     where hoi.organization_id = p_business_group_id
       and hoi.org_information_context||'' = 'CLASS' /* disable index */
       and hoi.org_information1 = 'HR_BG'
       and hoi.org_information2 = 'Y'
       and inf.organization_id = hoi.organization_id   --Bug 3633231
       and inf.org_information_context || '' = 'Business Group Information';
--
Begin
  --
  mandatory_arg_error(p_api_name       => l_proc,
                      p_argument       => 'business_group_id',
                      p_argument_value => p_business_group_id);
  --
  -- DK 2002-11-08 PLSQLSTD
  -- hr_utility.set_location(l_proc, 10);
  --
  -- Select the business group Id
  --
  Open Sel_Bus;
  fetch Sel_Bus Into l_legislation_code
                   , l_security_group_id;
  if Sel_Bus%notfound then
    Close Sel_Bus;
    l_column := nvl(p_associated_column1,'BUSINESS_GROUP_ID');
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_multi_message.add(p_associated_column1 => l_column);
  else
    Close Sel_Bus;
    --
    -- As the business_group_id is valid set CLIENT_INFO
    -- with the corresponding security_group_id
    --
    set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Also set the global variables used by the
    -- return_legislation_code.
    -- (The same tables have been visited to validate the
    -- business group. Setting the values here will save
    -- another select when return_legislation_code is called
    -- later on for the same business group.)
    --
    hr_api.g_business_group_id := p_business_group_id;
    hr_api.g_legislation_code  := l_legislation_code;
    --
    --  Call set_legislation_context to store the legislation_code
    --  for the session in the 'LEG_CODE' namespace of the 'HR_SESSION_DATA'
    --  application context, for reference by HR_LOOKUPS.
    --
    hr_api.set_legislation_context(l_legislation_code);
    -- Initialize the session context for bug 8250782.
    g_session_context := FND_GLOBAL.Get_Session_Context;
    --
  end if;
End validate_bus_grp_id;
--
-- --------------------- strip_constraint_name ------------------------------
--
-- Description: returns the constraint name from the error message
--
Function strip_constraint_name(p_errmsg	in varchar2)
         Return varchar2 Is
--
  l_proc        varchar2(72) := hr_api.g_package||'strip_constraint_name';
  l_pos1	number;
  l_pos2	number;
  l_pos3	number;
  l_return_str	varchar2(61);
--
Begin
  --
  mandatory_arg_error(p_api_name       => l_proc,
                      p_argument       => 'errmsg',
                      p_argument_value => p_errmsg);
  --
  l_pos1 := instr(p_errmsg, '(');
  l_pos2 := instr(p_errmsg, ')');
  --
  If ((l_pos1 = 0) or (l_pos2 = 0)) Then
    l_return_str := null;
  Else
    l_return_str := upper(substr(p_errmsg, l_pos1 + 1, l_pos2 - l_pos1 - 1));
    --
    -- Check to see if schema is present
    -- If it is strip it out!
    --
    l_pos3 := instr(l_return_str, '.');
    If (l_pos3 > 0) then
       l_return_str := substr(l_return_str, l_pos3 + 1,
                                            length(l_return_str) - l_pos3);
    End If;
  End If;
  --
  Return(l_return_str);
--
End strip_constraint_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_concat_kf_segments >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the display concatenated string for the segments1..30.
--   The function works by selecting all defined segments from the aol fnd
--   tables and determining if they have a value or if they are null. if null
--   then the concatenated segment delimiter is used.
--
-- Pre-conditions:
--   The id_flex_num and segments have been fully validated.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function return_concat_kf_segments
           (p_id_flex_num    in number,
            p_application_id in number,
            p_id_flex_code   in varchar2,
            p_segment1       in varchar2 default null,
            p_segment2       in varchar2 default null,
            p_segment3       in varchar2 default null,
            p_segment4       in varchar2 default null,
            p_segment5       in varchar2 default null,
            p_segment6       in varchar2 default null,
            p_segment7       in varchar2 default null,
            p_segment8       in varchar2 default null,
            p_segment9       in varchar2 default null,
            p_segment10      in varchar2 default null,
            p_segment11      in varchar2 default null,
            p_segment12      in varchar2 default null,
            p_segment13      in varchar2 default null,
            p_segment14      in varchar2 default null,
            p_segment15      in varchar2 default null,
            p_segment16      in varchar2 default null,
            p_segment17      in varchar2 default null,
            p_segment18      in varchar2 default null,
            p_segment19      in varchar2 default null,
            p_segment20      in varchar2 default null,
            p_segment21      in varchar2 default null,
            p_segment22      in varchar2 default null,
            p_segment23      in varchar2 default null,
            p_segment24      in varchar2 default null,
            p_segment25      in varchar2 default null,
            p_segment26      in varchar2 default null,
            p_segment27      in varchar2 default null,
            p_segment28      in varchar2 default null,
            p_segment29      in varchar2 default null,
            p_segment30      in varchar2 default null)
         return varchar2 is
--
  l_proc      varchar2(72) := hr_api.g_package||'return_concat_kf_segments';
  l_cat_str   varchar2(1800);
  l_error     exception;
  l_argn      varchar2(30);
  l_argv      varchar2(60);
  l_lc        number       := 0;
  l_seg_ind   boolean      := false;
--
  cursor kfsel is
    select idfst.concatenated_segment_delimiter	csd,
           idfsg.application_column_name	acn,
           idfsg.enabled_flag                   ef
    from   fnd_id_flex_segments   		idfsg,
           fnd_id_flex_structures 		idfst
    where  idfst.id_flex_num    = p_id_flex_num
    and    idfst.application_id = p_application_id
    and    idfst.id_flex_code   = p_id_flex_code
    and    idfsg.id_flex_num    = idfst.id_flex_num
    and    idfsg.application_id = idfst.application_id
    and    idfsg.id_flex_code   = idfst.id_flex_code
    order by idfsg.segment_num;
-- ----------------------------------------------------------------------------
   -- Description:
   --   Returns the concatenated segment string after processing the current
   --   segment.
   --
   -- Pre-conditions:
   --   none.
   --
   -- In Arguments:
   --   p_cat_str  -> current concatenated string under constrction
   --   p_segv     -> current segment value
   --   p_del      -> keyflex segment delimiter
   --   p_lc       -> current segment loop counter
   --
   -- Post Success:
   --   Concatenated segment string will have the current segment added to the
   --   build string under construction.
   --
   -- Post Failure:
   --   This function should not raise an error.
   --
   -- Access Status:
   --   Internal Table Handler Use Only (called by parent procedure
   --   return_concatenated_group_name.
-- ----------------------------------------------------------------------------
  function rtn_del_str(p_cat_str in varchar2,
                       p_segv    in varchar2,
                       p_del     in varchar2,
                       p_lc	 in number)
           return varchar2 is
  --
    l_rtn_str   varchar2(1800);
  --
  begin
    if (p_segv is not null) then
      --
      -- a segment has been set therefore we must set the indicator to true
      --
      l_seg_ind := true;
      --
      -- as the segment value exists we must determine if it is the
      -- the first segment
      --
      if (p_lc = 1) then
        --
        -- as the segment is first we must just assign the segment
        -- value
        --
        l_rtn_str := p_segv;
      else
        --
        -- as the segment is not the first one we must append the
        -- delimter and segment value to the returning str
        --
        l_rtn_str := p_cat_str||p_del||p_segv;
      end if;
    else
      if (p_lc = 1) then
        --
        -- as the segment value is null and is the first segment we
        -- return just a null value
        --
        l_rtn_str := null;
      else
        --
        -- the segment value is null but is not the first segment therefore
        -- we append the delimter to the current string
        --
        l_rtn_str := p_cat_str||p_del;
      end if;
    end if;
    return(l_rtn_str);
  end rtn_del_str;
--
begin
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'id_flex_num',
     p_argument_value => p_id_flex_num);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'application_id',
     p_argument_value => p_application_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'id_flex_code',
     p_argument_value => p_id_flex_code);
  --
  for kf in kfsel loop
    --
    l_lc := l_lc + 1;
    --
    if (kf.acn = 'SEGMENT1') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment1, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment1 is not null) then
        l_argn := 'P_SEGMENT1'; l_argv := p_segment1; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT2') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment2, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment2 is not null) then
        l_argn := 'P_SEGMENT2'; l_argv := p_segment2; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT3') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment3, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment3 is not null) then
        l_argn := 'P_SEGMENT3'; l_argv := p_segment3; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT4') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment4, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment4 is not null) then
        l_argn := 'P_SEGMENT4'; l_argv := p_segment4; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT5') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment5, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment5 is not null) then
        l_argn := 'P_SEGMENT5'; l_argv := p_segment5; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT6') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment6, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment6 is not null) then
        l_argn := 'P_SEGMENT6'; l_argv := p_segment6; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT7') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment7, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment7 is not null) then
        l_argn := 'P_SEGMENT7'; l_argv := p_segment7; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT8') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment8, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment8 is not null) then
        l_argn := 'P_SEGMENT8'; l_argv := p_segment8; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT9') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment9, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment9 is not null) then
        l_argn := 'P_SEGMENT9'; l_argv := p_segment9; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT10') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment10, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment10 is not null) then
        l_argn := 'P_SEGMENT10'; l_argv := p_segment10; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT11') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment11, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment11 is not null) then
        l_argn := 'P_SEGMENT11'; l_argv := p_segment11; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT12') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment12, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment12 is not null) then
        l_argn := 'P_SEGMENT12'; l_argv := p_segment12; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT13') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment13, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment13 is not null) then
        l_argn := 'P_SEGMENT13'; l_argv := p_segment13; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT14') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment14, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment14 is not null) then
        l_argn := 'P_SEGMENT14'; l_argv := p_segment14; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT15') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment15, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment15 is not null) then
        l_argn := 'P_SEGMENT15'; l_argv := p_segment15; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT16') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment16, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment16 is not null) then
        l_argn := 'P_SEGMENT16'; l_argv := p_segment16; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT17') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment17, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment17 is not null) then
        l_argn := 'P_SEGMENT17'; l_argv := p_segment17; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT18') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment18, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment18 is not null) then
        l_argn := 'P_SEGMENT18'; l_argv := p_segment18; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT19') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment19, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment19 is not null) then
        l_argn := 'P_SEGMENT19'; l_argv := p_segment19; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT20') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment20, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment20 is not null) then
        l_argn := 'P_SEGMENT20'; l_argv := p_segment20; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT21') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment21, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment21 is not null) then
        l_argn := 'P_SEGMENT21'; l_argv := p_segment21; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT22') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment22, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment22 is not null) then
        l_argn := 'P_SEGMENT22'; l_argv := p_segment22; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT23') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment23, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment23 is not null) then
        l_argn := 'P_SEGMENT23'; l_argv := p_segment23; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT24') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment24, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment24 is not null) then
        l_argn := 'P_SEGMENT24'; l_argv := p_segment24; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT25') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment25, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment25 is not null) then
        l_argn := 'P_SEGMENT25'; l_argv := p_segment25; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT26') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment26, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment26 is not null) then
        l_argn := 'P_SEGMENT26'; l_argv := p_segment26; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT27') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment27, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment27 is not null) then
        l_argn := 'P_SEGMENT27'; l_argv := p_segment27; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT28') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment28, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment28 is not null) then
        l_argn := 'P_SEGMENT28'; l_argv := p_segment28; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT29') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment29, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment29 is not null) then
        l_argn := 'P_SEGMENT29'; l_argv := p_segment29; raise l_error;
      end if;
    end if;
    if (kf.acn = 'SEGMENT30') then
      if (kf.ef = 'Y') then
        l_cat_str := rtn_del_str(l_cat_str, p_segment30, kf.csd, l_lc);
      elsif (kf.ef = 'N' and p_segment30 is not null) then
        l_argn := 'P_SEGMENT30'; l_argv := p_segment30; raise l_error;
      end if;
    end if;
    --
  end loop;
  if (l_lc > 0) then
    --
    -- If all the segment values are null then we must replace the delimited
    -- string will null
    --
    if not l_seg_ind then
      l_cat_str := null;
    end if;
  else
    --
    -- the flex structure cannot exist therefore error
    --
    l_argn := 'id_flex_num';
    l_argv := p_id_flex_num;
    raise l_error;
  end if;
  return(substr(l_cat_str, 1, 240));
exception
  when l_error then
    -- *** TEMP error message ***
    hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
    hr_utility.set_message_token('ARG_NAME', l_argn);
    hr_utility.set_message_token('ARG_VALUE', l_argv);
    hr_utility.raise_error;
  when others then
    raise;
end return_concat_kf_segments;
--
-- ----------------------------------------------------------------------------
-- |----------------------< not_exists_in_hr_lookups >------------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_hr_lookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Declare Local Variables
  --
  l_exists     varchar2(1);
  --
  -- Declare Local cursors
  --
  cursor csr_hr_look is
    select null
      from hr_lookups
     where lookup_code  = p_lookup_code
       and lookup_type  = p_lookup_type
       and enabled_flag = 'Y'
       and p_effective_date between
               nvl(start_date_active, p_effective_date)
           and nvl(end_date_active, p_effective_date);
  --
begin
  --
  -- When the lookup_type is YES_NO attempt to validate without
  -- executing the cursor. This is to reduce checking time for
  -- valid values in row handlers which have a lot of Yes No flags.
  --
  if p_lookup_type = 'YES_NO' then
    if p_lookup_code = 'Y' or p_lookup_code = 'N' then
      return false;
    end if;
    -- If the value is not known then go onto check against the
    -- hr_lookups view. Just in case there has been a change to
    -- the system defined lookup.
  end if;


  -- DK 2002-11-08 PLSQLSTD
  --hr_utility.set_location(hr_api.g_package||'not_exists_in_hr_lookups', 10);


  --
  open csr_hr_look;
  fetch csr_hr_look into l_exists;
  if csr_hr_look%notfound then
    close csr_hr_look;
    return true;
  else
    close csr_hr_look;
    return false;
  end if;
end not_exists_in_hr_lookups;
--
-- ----------------------------------------------------------------------------
-- |-------------------< not_exists_in_leg_lookups >-----------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_leg_lookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Declare Local Variables
  --
  l_exists     varchar2(1);
  --
  -- Declare Local cursors
  --
  cursor csr_hr_leg_look is
    select null
      from hr_leg_lookups
     where lookup_code  = p_lookup_code
       and lookup_type  = p_lookup_type
       and enabled_flag = 'Y'
       and p_effective_date between
               nvl(start_date_active, p_effective_date)
           and nvl(end_date_active, p_effective_date);
  --
begin
  --
  -- When the lookup_type is YES_NO attempt to validate without
  -- executing the cursor. This is to reduce checking time for
  -- valid values in row handlers which have a lot of Yes No flags.
  --
  if p_lookup_type = 'YES_NO' then
    if p_lookup_code = 'Y' or p_lookup_code = 'N' then
      return false;
    end if;
    -- If the value is not known then go onto check against the
    -- hr_lookups view. Just in case there has been a change to
    -- the system defined lookup.
  end if;
  hr_utility.set_location(hr_api.g_package||'not_exists_in_leg_lookups', 10);
  --
  open csr_hr_leg_look;
  fetch csr_hr_leg_look into l_exists;
  if csr_hr_leg_look%notfound then
    close csr_hr_leg_look;
    return true;
  else
    close csr_hr_leg_look;
    return false;
  end if;
end not_exists_in_leg_lookups;
--
-- ----------------------------------------------------------------------------
-- |---------------------< not_exists_in_hrstanlookups >----------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_hrstanlookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Declare Local Variables
  --
  l_exists  varchar2(1);
  --
  -- Declare Local cursors
  --
  cursor csr_hr_look is
    select null
      from hr_standard_lookups
     where lookup_code  = p_lookup_code
       and lookup_type  = p_lookup_type
       and enabled_flag = 'Y'
       and p_effective_date between
               nvl(start_date_active, p_effective_date)
           and nvl(end_date_active, p_effective_date);
  --
begin
  --
  -- When the lookup_type is YES_NO attempt to validate without
  -- executing the cursor. This is to reduce checking time for
  -- valid values in row handlers which have a lot of Yes No flags.
  --
  if p_lookup_type = 'YES_NO' then
    if p_lookup_code = 'Y' or p_lookup_code = 'N' then
      return false;
    end if;
    -- If the value is not known then go onto check against the
    -- hr_lookups view. Just in case there has been a change to
    -- the system defined lookup.
  end if;
  hr_utility.set_location(hr_api.g_package||'not_exists_in_hrstanlookups', 10);
  --
  open csr_hr_look;
  fetch csr_hr_look into l_exists;
  if csr_hr_look%notfound then
    close csr_hr_look;
    return true;
  else
    close csr_hr_look;
    return false;
  end if;
end not_exists_in_hrstanlookups;
--
-- ----------------------------------------------------------------------------
-- |---------------------< not_exists_in_fnd_lookups >------------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_fnd_lookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Declare Local Variables
  --
  l_exists  varchar2(1);
  --
  -- Declare Local cursors
  --
  cursor csr_fnd_look is
    select null
      from fnd_lookups
     where lookup_code  = p_lookup_code
       and lookup_type  = p_lookup_type
       and enabled_flag = 'Y'
       and p_effective_date between
               nvl(start_date_active, p_effective_date)
           and nvl(end_date_active, p_effective_date);
  --
begin
  --
  -- When the lookup_type is YES_NO attempt to validate without
  -- executing the cursor. This is to reduce checking time for
  -- valid values in row handlers which have a lot of Yes No flags.
  --
  if p_lookup_type = 'YES_NO' then
    if p_lookup_code = 'Y' or p_lookup_code = 'N' then
      return false;
    end if;
    -- If the value is not known then go onto check against the
    -- hr_lookups view. Just in case there has been a change to
    -- the system defined lookup.
  end if;
  hr_utility.set_location(hr_api.g_package||'not_exists_in_fnd_lookups', 10);
  --
  open csr_fnd_look;
  fetch csr_fnd_look into l_exists;
  if csr_fnd_look%notfound then
    close csr_fnd_look;
    return true;
  else
    close csr_fnd_look;
    return false;
  end if;
end not_exists_in_fnd_lookups;
--
-- ----------------------------------------------------------------------------
-- |--------------------< not_exists_in_dt_hr_lookups >-----------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_dt_hr_lookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- NOTE: At the moment this function does exactly the same validation
  -- as the not_exists_in_hr_lookups function. Currently the APIs do the
  -- same validation as the Form. i.e. Only check the code exists on the
  -- effective_date of the operation. This separate function has been provided
  -- because in the future we may want to introduce full date range validation.
  -- i.e. Check the lookup_code start_date_active end_date_active values span
  -- the vaidation_start_date to validation_end_date range of the DateTrack
  -- operation.
  -- The same issue applies to the not_exists_in_dt_hrstanlookups and
  -- not_exists_in_dt_fnd_lookups functions.
  --
begin
  --
  return not_exists_in_hr_lookups
           (p_effective_date => p_effective_date
           ,p_lookup_type    => p_lookup_type
           ,p_lookup_code    => p_lookup_code
           );
  --
end not_exists_in_dt_hr_lookups;
--
-- ----------------------------------------------------------------------------
-- |---------------------< not_exists_in_dt_leg_lookups >---------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_dt_leg_lookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- NOTE: At the moment this function does exactly the same validation
  -- as the not_exists_in_leg_lookups function. Currently the APIs do the
  -- same validation as the Form. i.e. Only check the code exists on the
  -- effective_date of the operation. This separate function has been provided
  -- because in the future we may want to introduce full date range validation.
  -- i.e. Check the lookup_code start_date_active end_date_active values span
  -- the vaidation_start_date to validation_end_date range of the DateTrack
  -- operation.
  -- The same issue applies to the not_exists_in_dt_hr_lookups,
  -- and not_exists_in_dt_hrstanlookups and
  -- not_exists_in_dt_fnd_lookups functions.
  --
begin
  --
  return not_exists_in_leg_lookups
           (p_effective_date => p_effective_date
           ,p_lookup_type    => p_lookup_type
           ,p_lookup_code    => p_lookup_code
           );
  --
end not_exists_in_dt_leg_lookups;
--
-- ----------------------------------------------------------------------------
-- |-------------------< not_exists_in_dt_hrstanlookups >---------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_dt_hrstanlookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Refer to code comments in not_exists_in_dt_hr_lookups for details of
  -- why this procedure exists and is currently coded to do the same
  -- validation as not_exists_in_hrstanlookups.
  --
begin
  --
  return not_exists_in_hrstanlookups
           (p_effective_date => p_effective_date
           ,p_lookup_type    => p_lookup_type
           ,p_lookup_code    => p_lookup_code
           );
  --
end not_exists_in_dt_hrstanlookups;
--
-- ----------------------------------------------------------------------------
-- |--------------------< not_exists_in_dt_fnd_lookups >----------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_dt_fnd_lookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Refer to code comments in not_exists_in_dt_hr_lookups for details of
  -- why this procedure exists and is currently coded to do the same
  -- validation as not_exists_in_fnd_lookups.
  --
begin
  --
  return not_exists_in_fnd_lookups
           (p_effective_date => p_effective_date
           ,p_lookup_type    => p_lookup_type
           ,p_lookup_code    => p_lookup_code
           );
  --
end not_exists_in_dt_fnd_lookups;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< cannot_find_prog_unit_error >--------------------|
-- ----------------------------------------------------------------------------
--
procedure cannot_find_prog_unit_error
  (p_module_name   in varchar2
  ,p_hook_type     in varchar2
  ) is
  --
  -- Cursor to obtain the user description for the hook_type
  --
  cursor csr_hook_type is
    select meaning
      from hr_lookups
     where lookup_type  = 'API_HOOK_TYPE'
       and enabled_flag = 'Y'
       and lookup_code  = p_hook_type;
  --
  -- Local variables
  --
  l_hook_type  varchar2(80);
  l_proc       varchar2(72) := hr_api.g_package||'cannot_find_prog_unit_error';
begin
  hr_utility.set_location(l_proc, 10);
  --
  -- Attempt to find the user description for the hook type.
  -- If it cannot be found just use the internal code value.
  --
  open csr_hook_type;
  fetch csr_hook_type into l_hook_type;
  if csr_hook_type%notfound then
    l_hook_type := p_hook_type;
  end if;
  close csr_hook_type;
  --
  -- Error: The system cannot find the program unit being called. This could
  -- be because the application API pre-processor has not been run. Contact
  -- your system administrator quoting the following details:
  -- Error ORA-06508 in API module *MODULE_NAME at hook *HOOK_TYPE.
  --
  hr_utility.set_message(800, 'HR_51938_AHK_NOT_FIND_UNIT');
  hr_utility.set_message_token('MODULE_NAME', p_module_name);
  hr_utility.set_message_token('HOOK_TYPE', l_hook_type);
  hr_utility.raise_error;
end cannot_find_prog_unit_error;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< return_commit_unit >-------------------------|
-- ----------------------------------------------------------------------------
--
function return_commit_unit return number is
  l_lock_status       number;
begin
  --
  -- Request a RDBMS lock which will be released on commit or rollback.
  --
  l_lock_status := dbms_lock.request(2147483647, dbms_lock.nl_mode, 0, TRUE);
  if l_lock_status = 0 then
    --
    -- The lock has just been obtained. As far as this function is concerned
    -- it is the start of the commit unit. Increment the commit unit number.
    --
    -- When the l_lock_status is not zero, either there was error (1, 2, 3, 5)
    -- or the lock was obtained on a previous call to this function (4). If
    -- the lock has already been obtained, the commit unit cannot have
    -- changed, so number is not incremented.
    --
    hr_api.g_commit_unit_number := hr_api.g_commit_unit_number + 1;
  end if;
  --
  return hr_api.g_commit_unit_number;
end return_commit_unit;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< validate_commit_unit >------------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_commit_unit
  (p_commit_unit_number  in number
  ,p_module_name         in varchar2
  ,p_hook_type           in varchar2
  ) is
  --
  -- Cursor to obtain the user description for the hook_type
  --
  cursor csr_hook_type is
    select meaning
      from hr_lookups
     where lookup_type  = 'API_HOOK_TYPE'
       and enabled_flag = 'Y'
       and lookup_code  = p_hook_type;
  --
  -- Local variables
  --
  l_hook_type     varchar2(80);
  l_proc          varchar2(72) := hr_api.g_package||'validate_commit_unit';
begin
  hr_utility.set_location(l_proc, 10);
  --
  -- Attempt to find the user description for the hook type.
  -- If it cannot be found just use the internal code value.
  --
  -- Bug fix 3390390:
  -- Moved following cursor to inside the following IF..THEN logic
  -- open csr_hook_type;
  -- fetch csr_hook_type into l_hook_type;
  -- if csr_hook_type%notfound then
  --   l_hook_type := p_hook_type;
  -- end if;
  -- close csr_hook_type;
  --
  -- If the current commit unit number does not equal the number passed to
  -- this procedure then raise an error. A commit or full rollback must have
  -- been issued since return_commit_unit was last called.
  --
  if return_commit_unit <> p_commit_unit_number then
    -- Error: An internal commit or full rollback has occurred inside this API
    -- user hook. These commands are not permitted as they interfere with
    -- other logic. Contact your system administrator to resolve this action
    -- and to remove the commit or rollback statement. Quote:
    -- API module *MODULE_NAME at hook *HOOK_TYPE.
    --
    -- Execute cursor (fix 3390930)
    open csr_hook_type;
    fetch csr_hook_type into l_hook_type;
    if csr_hook_type%notfound then
       l_hook_type := p_hook_type;
    end if;
    close csr_hook_type;
    --
    hr_utility.set_message(800, 'HR_51939_AHK_COMMIT_FOUND');
    hr_utility.set_message_token('MODULE_NAME', p_module_name);
    hr_utility.set_message_token('HOOK_TYPE', l_hook_type);
    hr_utility.raise_error;
  end if;
end validate_commit_unit;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< customer_hooks >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure customer_hooks
  (p_mode                in varchar2
  ) is
begin
  if p_mode = 'DISABLE' then
    hr_api.g_call_cus_api_hooks := false;
  elsif p_mode = 'ENABLE' then
    hr_api.g_call_cus_api_hooks := true;
  else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE'
                                ,hr_api.g_package||'customer_hooks'
                                );
    hr_utility.set_message_token('STEP', '20');
    hr_utility.raise_error;
  end if;
end customer_hooks;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< legislation_hooks >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure legislation_hooks
  (p_mode                in varchar2
  ) is
begin
  if p_mode = 'DISABLE' then
    hr_api.g_call_leg_api_hooks := false;
  elsif p_mode = 'ENABLE' then
    hr_api.g_call_leg_api_hooks := true;
  else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', hr_api.g_package||'leg_hooks');
    hr_utility.set_message_token('STEP', '20');
    hr_utility.raise_error;
  end if;
end legislation_hooks;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< application_hooks >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure application_hooks
  (p_mode                in varchar2
  ) is
begin
  if p_mode = 'DISABLE' then
    hr_api.g_call_app_api_hooks := false;
  elsif p_mode = 'ENABLE' then
    hr_api.g_call_app_api_hooks := true;
  else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', hr_api.g_package||'app_hooks');
    hr_utility.set_message_token('STEP', '20');
    hr_utility.raise_error;
  end if;
end application_hooks;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< call_cus_hooks >----------------------------|
-- ----------------------------------------------------------------------------
--
function call_cus_hooks return boolean is
begin
  return hr_api.g_call_cus_api_hooks;
end call_cus_hooks;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< call_leg_hooks >----------------------------|
-- ----------------------------------------------------------------------------
--
function call_leg_hooks return boolean is
begin
  return hr_api.g_call_leg_api_hooks;
end call_leg_hooks;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< call_app_hooks >----------------------------|
-- ----------------------------------------------------------------------------
function call_app_hooks return boolean is
begin
  return hr_api.g_call_app_api_hooks;
end call_app_hooks;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< return_legislation_code >----------------------|
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_business_group_id    in   number
  ) return varchar2 is
  --
  -- Cursor to find the legislation_code
  --
  cursor csr_leg_code is
    select legislation_code
      from per_business_groups_perf
     where business_group_id = p_business_group_id;
  --
  l_legislation_code  varchar2(30);
begin
  if p_business_group_id is null then
    --
    -- No business group has been provided to this function
    -- so return a null legislation_code
    --
    l_legislation_code := null;
  else
    if nvl(hr_api.g_business_group_id, hr_api.g_number) = p_business_group_id
      then
      --
      -- The legislation code for the business group has already
      -- been found with a previous call to this function or to
      -- validate_bus_grp_id. Just return the value in the global
      -- variable to avoid the overhead of executing the cursor statement.
      --
      l_legislation_code := hr_api.g_legislation_code;
    else
      hr_utility.set_location(hr_api.g_package||'return_legislation_code', 10);
      --
      -- The business_group_id is different to the last call to this
      -- function or this is the first call to this function.
      --
      open csr_leg_code;
      fetch csr_leg_code into l_legislation_code;
      if csr_leg_code%notfound then
        close csr_leg_code;
        hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
        hr_utility.raise_error;
      end if;
      close csr_leg_code;
      --
      -- Set the global variables for the next call
      --
      hr_api.g_business_group_id := p_business_group_id;
      hr_api.g_legislation_code  := l_legislation_code;
    end if;
  end if;
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< userenv_lang >-------------------------------|
-- ----------------------------------------------------------------------------
--
function userenv_lang return varchar2
is
begin
  -- DK 2002-11-08 PLSQLSTD
  return(userenv('LANG'));
end userenv_lang;
--
-- ----------------------------------------------------------------------------
-- |------------------------< validate_language_code >------------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_language_code
(p_language_code                 in out nocopy varchar2
) is
  --
  -- Language validation cursor
  --
  cursor csr_val_lang(l_lang varchar2) is
    select null
      from fnd_languages lan
     where lan.installed_flag in ('I', 'B')
       and lan.language_code  = l_lang;
  --
  -- Local variables
  --
  l_language_code  varchar2(30);
  l_exists         varchar2(1);
begin
  --
  -- When a null or hr_api.g_varchar2 value is
  -- provided use userenv('LANG') instead.
  --
  if (p_language_code is null) or
     (p_language_code = hr_api.g_varchar2) then
    l_language_code := userenv_lang;
  else
    l_language_code := p_language_code;
  end if;
  hr_utility.set_location(hr_api.g_package||'validate_language_code', 10);
  --
  -- Validate that the language to be used is the application
  -- base language or an installed language.
  --
  open csr_val_lang(l_language_code);
  fetch csr_val_lang into l_exists;
  if csr_val_lang%notfound then
    close csr_val_lang;
    -- Error: The language specified must be the base language or an
    --        installed language.
    hr_utility.set_message(800, 'HR_52499_API_BASE_INSTALL_LANG');
    hr_utility.raise_error;
  end if;
  close csr_val_lang;
  --
  -- Output the valid language
  --
  p_language_code := l_language_code;
  --
end validate_language_code;

--
-- ----------------------------------------------------------------------------
-- |------------------------< set_legislation_context >------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_legislation_context
(p_legislation_code                 in varchar2
) is
--

--  For backward compatibility, continue the  initialization of application
--  context HR_SESSION_DATA/LEG_CODE

begin
g_leg_code := p_legislation_code;
  -- DK 2002-11-08 PLSQLSTD
  DBMS_SESSION.SET_CONTEXT('HR_SESSION_DATA','LEG_CODE',p_legislation_code);
end set_legislation_context;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_legislation_context >------------------------|
-- ----------------------------------------------------------------------------
--
function get_legislation_context return varchar2 is
--
l_leg_code PER_BUSINESS_GROUPS_PERF.LEGISLATION_CODE%TYPE;
begin
-- Check for session context change and initialize legislation code accordingly
 IF NOT (FND_GLOBAL.COMPARE_SESSION_CONTEXT(g_session_context))
 THEN
-- Initialize the session context
 g_session_context := FND_GLOBAL.Get_Session_Context;

 -- Get the legislation code from BG
 l_leg_code :=  hr_api.return_legislation_code(fnd_profile.value('PER_BUSINESS_GROUP_ID'));

 -- Set application context HR_SESSION_DATA/LEG_CODE
 set_legislation_context(l_leg_code);
 --
 END IF;

  RETURN g_leg_code;
end get_legislation_context;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< constant_to_boolean >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Used in the Self Service API wrappers to convert constant values to the
--  appropriate boolean ones.
--
-- ----------------------------------------------------------------------------
FUNCTION constant_to_boolean(p_constant_value IN number) RETURN boolean IS
BEGIN
  IF p_constant_value = hr_api.g_false_num THEN
     RETURN false;
  ELSE
     RETURN true;
  END IF;
END constant_to_boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< boolean_to_constant >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Used in the Self Service API wrappers to convert constant values to the
--  appropriate boolean ones.
--
-- ----------------------------------------------------------------------------
FUNCTION boolean_to_constant(p_boolean_value IN boolean) RETURN number IS
BEGIN
  IF p_boolean_value THEN
     RETURN hr_api.g_true_num;
  ELSE
     RETURN hr_api.g_false_num;
  END IF;
END boolean_to_constant;
--
End HR_Api;

/
