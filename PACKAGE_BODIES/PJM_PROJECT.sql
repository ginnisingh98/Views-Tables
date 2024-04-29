--------------------------------------------------------
--  DDL for Package Body PJM_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PROJECT" as
/* $Header: PJMPROJB.pls 120.7.12010000.2 2008/09/17 06:43:10 ybabulal ship $ */

FUNCTION Proj_Or_Seiban
( X_project_id  IN NUMBER
) return varchar2 IS

L_proj_id NUMBER;
L_seiban NUMBER;
L_flag VARCHAR2(10) := 'N';

CURSOR p IS
select project_id from pa_projects_all
where project_id = X_project_id;

CURSOR s IS
select project_id from pjm_seiban_numbers
where project_id = X_project_id;

BEGIN

open p;
fetch p into L_proj_id;
if (p%notfound) then
  open s;
  fetch s into L_seiban;
  if (s%notfound) then L_flag := 'N';
  else L_flag := 'S';
  end if;
  close s;
else L_flag := 'P';
end if;

close p;
return (L_flag);

END Proj_Or_Seiban;


FUNCTION Is_Exp_Proj
( X_project_id  IN NUMBER ,
  X_org_id      IN NUMBER
) return varchar2 IS

L_proj_id NUMBER;

BEGIN

select project_id into L_proj_id
from pa_projects_all_expend_v
where project_id = X_project_id
and expenditure_org_id = X_org_id;

return ('Y');

exception
 when others then
  return ('N');

END Is_Exp_Proj;


-- Private Function
--

FUNCTION Org_ID
( X_inv_org  IN  NUMBER
) RETURN NUMBER IS

  L_Org_ID NUMBER;

  CURSOR c IS
  select TO_NUMBER(org_information3)
  from hr_organization_information
  where ( ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
  and organization_id = X_inv_org;
  --FND_PROFILE.VALUE('MFG_ORGANIZATION_ID');

BEGIN

  -- Get the ou from inventory org default
  OPEN c;
  FETCH c INTO L_Org_ID;
  CLOSE c;

  -- If no mfg_organiation_id setup, then go for MOAC routine and client_info logic
-- BUG fix 5479390, should not use CLIENT_INFO as it is going away in R12.
  -- IF L_Org_ID IS NULL THEN
    -- L_Org_ID := to_number(rtrim(substr( userenv('CLIENT_INFO') , 1 , 10 ))) ;
  -- END IF;

  RETURN L_Org_ID;

END Org_ID;

--
-- Public Functions and Procedures
--

function all_proj_idtonum
( X_project_id          in number
) return varchar2 IS
L_project_num           varchar2(30);
cursor C1 is
   select segment1
   from	  pa_projects_all
   where  project_id = X_project_id
   union
   select project_number
   from   pjm_seiban_numbers
   where  project_id = X_project_id;

begin

   if X_project_id is null then
      return null;
   end if;

   open c1;
   fetch c1 into L_project_num;
   close c1;

   return L_project_num;

end all_proj_idtonum;


function all_proj_idtoname
( X_project_id          in number
) return varchar2 IS
L_project_name          varchar2(30);
cursor C1 is
   select name
   from	  pa_projects_all
   where  project_id = X_project_id
   union
   select project_name
   from   pjm_seiban_numbers
   where  project_id = X_project_id;

begin

   if X_project_id is null then
      return null;
   end if;

   open c1;
   fetch c1 into L_project_name;
   close c1;

   return L_project_name;

end all_proj_idtoname;


function val_proj_idtonum
( X_project_id          in number
, X_organization_id     in number
) return varchar2 IS
L_project_num           varchar2(30);
L_dummy                 number;
cursor C1 is
   select project_number
   from	  PJM_PROJECTS_ORG_OU_SECURE_V          /*Bug 6684081: Changed the view that should be used for MOAC. This API is called by OM team.*/
   where  project_id = X_project_id;

cursor C2 is
   select 1
   from   pjm_project_parameters
   where  project_id = X_project_id
   and    organization_id = X_organization_id;

-- Bug Fix 7337239
cursor C3 is
   select project_number
   from	  PJM_PROJECTS_V
   where  project_id = X_project_id;

begin

   if X_project_id is null then
      return null;
   end if;

   IF  X_organization_id IS NULL THEN
     open c1;
     fetch c1 into L_project_num;
     close c1;
   else
     open c3;
     fetch c3 into L_project_num;
     close c3;
   end if;

   if X_organization_id is not null then
      open c2;
      fetch c2 into L_dummy;
      close c2;
      if L_dummy is null then
         return null;
      end if;
   end if;

   return L_project_num;

end val_proj_idtonum;


function val_proj_idtoname
( X_project_id          in number
, X_organization_id     in number
) return varchar2 IS
L_project_name          varchar2(30);
L_dummy                 number;
cursor C1 is
   select project_name
   from	  pjm_projects_v
   where  project_id = X_project_id;

cursor C2 is
   select 1
   from   pjm_project_parameters
   where  project_id = X_project_id
   and    organization_id = X_organization_id;

begin

   if X_project_id is null then
      return null;
   end if;

   open c1;
   fetch c1 into L_project_name;
   close c1;

   if X_organization_id is not null then
      open c2;
      fetch c2 into L_dummy;
      close c2;
      if L_dummy is null then
         return null;
      end if;
   end if;

   return L_project_name;

end val_proj_idtoname;


function val_proj_numtoid
( X_project_num         in varchar2
, X_organization_id     in number
) return number IS
L_project_id            number;
L_dummy                 number;
cursor C1 is
   select project_id
   from	  pjm_projects_v
   where  project_number = X_project_num;

cursor C2 is
   select 1
   from   pjm_project_parameters
   where  project_id = L_project_id
   and    organization_id = X_organization_id;

begin

   if X_project_num is null then
      return null;
   end if;

   open c1;
   fetch c1 into L_project_id;
   close c1;

   if X_organization_id is not null then
      open c2;
      fetch c2 into L_dummy;
      close c2;
      if L_dummy is null then
         return null;
      end if;
   end if;

   return L_project_id;

end val_proj_numtoid;


function val_proj_nametoid
( X_project_name        in varchar2
, X_organization_id     in number
) return number IS
L_project_id            number;
L_dummy                 number;
cursor C1 is
   select project_id
   from	  pjm_projects_v
   where  project_name = X_project_name;

cursor C2 is
   select 1
   from   pjm_project_parameters
   where  project_id = L_project_id
   and    organization_id = X_organization_id;

begin

   if X_project_name is null then
      return null;
   end if;

   open c1;
   fetch c1 into L_project_id;
   close c1;

   if X_organization_id is not null then
      open c2;
      fetch c2 into L_dummy;
      close c2;
      if L_dummy is null then
         return null;
      end if;
   end if;

   return L_project_id;

end val_proj_nametoid;


function all_task_idtonum
( X_task_id             in number
) return varchar2 IS
L_task_num              varchar2(25);
cursor C1 is
   select task_number
   from	  pa_tasks
   where  task_id = X_task_id;

begin

   if X_task_id is null then
      return null;
   end if;

   open c1;
   fetch c1 into L_task_num;
   close c1;

   return L_task_num;

end all_task_idtonum;


function all_task_idtoname
( X_task_id             in number
) return varchar2 IS
L_task_name             varchar2(20);
cursor C1 is
   select task_name
   from	  pa_tasks
   where  task_id = X_task_id;

begin

   if X_task_id is null then
      return null;
   end if;

   open c1;
   fetch c1 into L_task_name;
   close c1;

   return L_task_name;

end all_task_idtoname;


function val_task_idtonum
( X_project_id          in number
, X_task_id             in number
) return varchar2 IS
L_task_num              varchar2(25);
cursor C1 is
   select task_number
   from	  pjm_tasks_v
   where  project_id = X_project_id
   and    task_id = X_task_id;

begin

   if X_task_id is null then
      return null;
   end if;

   if ( val_proj_idtonum(X_project_id) is null ) then
      return null;
   end if;

   open c1;
   fetch c1 into L_task_num;
   close c1;

   return L_task_num;

end val_task_idtonum;


function val_task_idtoname
( X_project_id          in number
, X_task_id             in number
) return varchar2 IS
L_task_name             varchar2(20);
cursor C1 is
   select task_name
   from	  pjm_tasks_v
   where  project_id = X_project_id
   and    task_id = X_task_id;

begin

   if X_task_id is null then
      return null;
   end if;

   if ( val_proj_idtonum(X_project_id) is null ) then
      return null;
   end if;

   open c1;
   fetch c1 into L_task_name;
   close c1;

   return L_task_name;

end val_task_idtoname;


function val_task_numtoid
( X_project_num         in varchar2
, X_task_num            in varchar2
) return number IS
L_project_id            number;
L_task_id               number;
cursor C1 is
   select task_id
   from	  pjm_tasks_v
   where  project_id = L_project_id
   and    task_number = X_task_num;

begin

   if X_task_num is null then
      return null;
   end if;

   L_project_id := val_proj_numtoid(X_project_num);

   open c1;
   fetch c1 into L_task_id;
   close c1;

   return L_task_id;

end val_task_numtoid;


function val_task_nametoid
( X_project_name        in varchar2
, X_task_name           in varchar2
) return number IS
L_project_id            number;
L_task_id               number;
cursor C1 is
   select task_id
   from	  pjm_tasks_v
   where  project_id = L_project_id
   and    task_name = X_task_name;

begin

   if X_task_name is null then
      return null;
   end if;

   L_project_id := val_proj_nametoid(X_project_name);

   open c1;
   fetch c1 into L_task_id;
   close c1;

   return L_task_id;

end val_task_nametoid;


--
-- Validate project references for a particular calling function
--

--
-- This variant provides backward compatibility where an early version
-- did not include date parameters
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_project_id          in         number
, X_task_id             in         number
, X_calling_function    in         varchar2
, X_error_code          out nocopy varchar2
) return boolean IS

retcode               varchar2(1);

begin

  retcode := validate_proj_references
             ( X_inventory_org_id    => X_inventory_org_id
             , X_operating_unit      => Org_ID(X_inventory_org_id)
             , X_project_id          => X_project_id
             , X_task_id             => X_task_id
             , X_date1               => NULL
             , X_date2               => NULL
             , X_calling_function    => X_calling_function
             , X_error_code          => X_error_code
             );

  if ( retcode = G_VALIDATE_SUCCESS ) then
    return ( TRUE );
  else
    return ( FALSE );
  end if;

end validate_proj_references;


--
-- This variant does not include the error code out parameter
-- and can be used in SQL
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_project_id          in         number
, X_task_id             in         number
, X_date1               in         date
, X_date2               in         date
, X_calling_function    in         varchar2
) return varchar2 IS

retcode               varchar2(1);
errcode               varchar2(240);

begin

  retcode := validate_proj_references
             ( X_inventory_org_id    => X_inventory_org_id
             , X_operating_unit      => Org_ID(X_inventory_org_id)
             , X_project_id          => X_project_id
             , X_task_id             => X_task_id
             , X_date1               => X_date1
             , X_date2               => X_date2
             , X_calling_function    => X_calling_function
             , X_error_code          => errcode
             );

  return ( retcode );

end validate_proj_references;


--
-- This variant uses the current operating unit as the default
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_project_id          in         number
, X_task_id             in         number
, X_date1               in         date     default null
, X_date2               in         date     default null
, X_calling_function    in         varchar2
, X_error_code          out nocopy varchar2
) return varchar2 IS

retcode               varchar2(1);

begin

  retcode := validate_proj_references
             ( X_inventory_org_id    => X_inventory_org_id
             , X_operating_unit      => Org_ID(X_inventory_org_id)
             , X_project_id          => X_project_id
             , X_task_id             => X_task_id
             , X_date1               => X_date1
             , X_date2               => X_date2
             , X_calling_function    => X_calling_function
             , X_error_code          => X_error_code
             );

  return ( retcode );

end validate_proj_references;


--
-- This is the main definition of the function
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_operating_unit      in         number
, X_project_id          in         number
, X_task_id             in         number
, X_date1               in         date
, X_date2               in         date
, X_calling_function    in         varchar2
, X_error_code          out nocopy varchar2
) return varchar2 IS

L_proj_ctrl_level     varchar2(10);
L_project_number      varchar2(30);
L_org_code            varchar2(30);
L_operating_unit      number;
retcode               varchar2(80);
retsts                varchar2(1);
start_date            date;
end_date              date;
param_start_date      date;
param_end_date        date;
project_num           varchar2(30);
task_num              varchar2(30);
warnings              number;
failures              number;
msgcount              number;
msgdata               varchar2(2000);
i                     number;
projflag              varchar2(10);

VALIDATE_FAILURE      exception;
VALIDATE_WARNING      exception;

--
-- Cursor to check implementation of PJM and project control level
--
cursor pop is
  select mp.organization_code
  ,      decode(pop.organization_id ,
                null , 'GEN-ORG NOT PJM ENABLED' ,
                       decode(pop.project_reference_enabled ,
                              'N' , 'GEN-ORG NOT PRJ REF ENABLED' ,
                                    null))
  ,      decode(pop.project_control_level, 1, 'PROJECT', 2, 'TASK')
  from   pjm_org_parameters pop
  ,      mtl_parameters mp
  where  mp.organization_id = X_inventory_org_id
  and    pop.organization_id (+) = mp.organization_id;

--
-- Cursor to check
-- 1) Project is chargeable or not
-- 2) Project setup for current inventory org or not
-- 3) Start / End date for further processing
--
cursor proj is
  select p.segment1
  ,      decode(pp.project_id ,
           null , 'GEN-INVALID PROJ FOR ORG',
           decode(PJM_PROJECT.Is_Exp_Proj(p.project_id,L_operating_unit),
                 'Y', null,
                  decode(p.org_id,
                         L_operating_unit, 'GEN-INVALID PROJ' ,
                         'GEN-INVALID PROJ FOR OU')))
  ,      trunc(p.start_date)
  ,      trunc(p.completion_date)
  ,      trunc(pp.start_date_active)
  ,      trunc(pp.end_date_active)
  from   pa_projects_all p
  ,      pjm_project_parameters pp
  where  p.project_id = X_project_id
  and    pp.project_id (+) = p.project_id
  and    pp.organization_id (+) = X_inventory_org_id;

cursor seiban is
  select sn.project_number
  ,      decode(pp.project_id ,
                null , 'GEN-INVALID PROJ FOR ORG' , null)
  ,      to_date(null)
  ,      to_date(null)
  ,      trunc(pp.start_date_active)
  ,      trunc(pp.end_date_active)
  from   pjm_seiban_numbers sn
  ,      pjm_project_parameters pp
  where  sn.project_id = X_project_id
  and    pp.organization_id (+) = X_inventory_org_id
  and    pp.project_id (+) = sn.project_id;

--
-- Cursor to check
-- 1) Task is valid or not
-- 2) Task is chargeable or not
-- 3) Start / End date for further processing
--
cursor task is
  select te.task_number
  ,      decode(te.chargeable_flag ,
         'N' , 'GEN-TASK NOT CHARGEABLE' , null)
  ,      trunc(te.start_date)
  ,      trunc(te.completion_date)
  from   pa_tasks_all_expend_v te
  where  te.task_id = X_task_id
  and    te.project_id = X_project_id
  and    te.expenditure_org_id = L_operating_unit;

cursor base_task is
  select t.task_number
  ,     'GEN-INVALID TASK'
  ,      trunc(t.start_date)
  ,      trunc(t.completion_date)
  from   pa_tasks t
  where  t.task_id = X_task_id
  and    t.project_id = X_project_id;

begin
  --
  -- if project is not given, no need for further processing
  --
  if ( X_project_id is null ) then
    return( G_VALIDATE_SUCCESS );
  end if;

  --
  -- Initialize the message table
  --
  fnd_msg_pub.initialize;

  --
  -- Initialize the failure and warning counts
  --
  failures := 0;
  warnings := 0;

  --
  -- First make sure org is PJM enabled and retrieve
  -- project control level
  --
  open pop;
  fetch pop into L_org_code , retcode , L_proj_ctrl_level;
  if ( pop%notfound ) then
    X_error_code := 'GEN-ORG ID INVALID';
    FND_MESSAGE.set_name('PJM', X_error_code);
    FND_MESSAGE.set_token('ID', X_inventory_org_id);
    FND_MSG_PUB.add;
    failures := failures + 1;
  end if;

  close pop;

  if ( retcode is not null ) then
    X_error_code := retcode;
    FND_MESSAGE.set_name('PJM', X_error_code);
    FND_MESSAGE.set_token('ORG', L_org_code);
    FND_MSG_PUB.add;
    failures := failures + 1;
  end if;

  L_operating_unit := nvl( X_operating_unit , Org_ID(X_inventory_org_id) );
  projflag := pjm_project.proj_or_seiban(X_project_id);

  --
  -- Now validating project reference; invalid if cursor returns
  -- retcode value
  --
  if (projflag = 'P') then
    open proj;
    fetch proj into project_num , retcode , start_date , end_date
                , param_start_date , param_end_date;
    close proj;
  elsif (projflag = 'S') then
    open seiban;
    fetch seiban into project_num , retcode , start_date , end_date
                , param_start_date , param_end_date;
    close seiban;
  else
  --
  -- Not Project or Seiban: project ID is not valid
  --
    X_error_code := 'GEN-PROJ ID INVALID';
    FND_MESSAGE.set_name('PJM' , X_error_code);
    FND_MESSAGE.set_token('ID' , X_project_id);
    FND_MSG_PUB.add;
    failures := failures + 1;
  end if;

  if (projflag = 'P' or projflag = 'S') then
  if ( retcode is not null ) then
    X_error_code := retcode;
    FND_MESSAGE.set_name('PJM', X_error_code);
    FND_MESSAGE.set_token('PROJECT', project_num);
    FND_MSG_PUB.add;
    failures := failures + 1;
  else
    --
    -- Project valid; now check against date
    --
    if ( X_date1 is not null ) then
      if not ( trunc(X_date1) >= nvl(start_date , trunc(X_date1) - 1) and
               trunc(X_date1) <= nvl(end_date , trunc(X_date1) + 1) ) then
        --
        -- X_date1 falls out of start/end date window
        --
        X_error_code := 'GEN-INVALID DATE FOR PROJ';
        FND_MESSAGE.set_name('PJM', X_error_code);
        FND_MESSAGE.set_token('DATE', X_date1);
        FND_MSG_PUB.add;
        warnings := warnings + 1;
      end if;

      if not ( trunc(X_date1) >= nvl(param_start_date , trunc(X_date1) - 1) and
               trunc(X_date1) <= nvl(param_end_date , trunc(X_date1) + 1) ) then
        --
        -- X_date1 falls out of parameter start/end date window
        --
        X_error_code := 'GEN-INVALID DATE FOR ORG';
        FND_MESSAGE.set_name('PJM', X_error_code);
        FND_MESSAGE.set_token('DATE', X_date1);
        FND_MSG_PUB.add;
        warnings := warnings + 1;
      end if;
    end if;

    if ( X_date2 is not null ) then
      if not ( trunc(X_date2) >= nvl(start_date , trunc(X_date2) - 1) and
               trunc(X_date2) <= nvl(end_date , trunc(X_date2) + 1) ) then
        --
        -- X_date2 falls out of start/end date window
        --
        X_error_code := 'GEN-INVALID DATE FOR PROJ';
        FND_MESSAGE.set_name('PJM', X_error_code);
        FND_MESSAGE.set_token('DATE', X_date2);
        FND_MSG_PUB.add;
        warnings := warnings + 1;
      end if;

      if not ( trunc(X_date2) >= nvl(param_start_date , trunc(X_date2) - 1) and
               trunc(X_date2) <= nvl(param_end_date , trunc(X_date2) + 1) ) then
        --
        -- X_date2 falls out of start/end date window
        --
        X_error_code := 'GEN-INVALID DATE FOR ORG';
        FND_MESSAGE.set_name('PJM', X_error_code);
        FND_MESSAGE.set_token('DATE', X_date2);
        FND_MSG_PUB.add;
        warnings := warnings + 1;
      end if;
    end if;

--  end if; -- check task only if project is valid

  if ( X_task_id is null ) then
    --
    -- No task reference present; make sure complies with project
    -- control level
    --
    if ( L_proj_ctrl_level = 'TASK' ) then
      X_error_code := 'GEN-INVALID PROJ REF';
      FND_MESSAGE.set_name('PJM', X_error_code);
      FND_MESSAGE.set_token('ORG', L_org_code);
      FND_MSG_PUB.add;
      failures := failures + 1;
    end if;

  else

    open task;
    fetch task into task_num , retcode , start_date , end_date;

    --
    -- If the cursor returns nothing, then the task is
    -- not not in pa_tasks_all_expend_v
    --
    if ( task%notfound ) then

      open base_task; -- Check if the task is in base table
      fetch base_task into task_num , retcode , start_date , end_date;

      -- If the base_task cursor returns nothing, then
      -- either the task does not exist or not for this project
      if ( base_task%notfound ) then
        X_error_code := 'GEN-TASK ID INVALID';
        FND_MESSAGE.set_name('PJM' , X_error_code);
        FND_MESSAGE.set_token('ID' , X_task_id);
        FND_MSG_PUB.add;
        failures := failures + 1;
      else
        X_error_code := retcode;
        FND_MESSAGE.set_name('PJM' , X_error_code);
        FND_MESSAGE.set_token('TASK' , task_num);
        FND_MSG_PUB.add;
        failures := failures + 1;
      end if;

    --
    -- Task reference invalid if cursor returns retcode value
    --
    elsif ( retcode is not null ) then

      X_error_code := retcode;
      FND_MESSAGE.set_name('PJM', X_error_code);
      FND_MESSAGE.set_token('TASK', task_num);
      FND_MSG_PUB.add;
      failures := failures + 1;

    else

      if ( X_date1 is not null ) then
        if not ( trunc(X_date1) >= nvl(start_date , trunc(X_date1) - 1) and
                 trunc(X_date1) <= nvl(end_date , trunc(X_date1) + 1) ) then
          --
          -- X_date1 falls out of start/end date window
          --
          X_error_code := 'GEN-INVALID DATE FOR TASK';
          FND_MESSAGE.set_name('PJM', X_error_code);
          FND_MESSAGE.set_token('DATE', X_date1);
          FND_MSG_PUB.add;
          warnings := warnings + 1;
        end if;
      end if;

      if ( X_date2 is not null ) then
        if not ( trunc(X_date2) >= nvl(start_date , trunc(X_date2) - 1) and
                 trunc(X_date2) <= nvl(end_date , trunc(X_date2) + 1) ) then
          --
          -- X_date2 falls out of start/end date window
          --
          X_error_code := 'GEN-INVALID DATE FOR TASK';
          FND_MESSAGE.set_name('PJM', X_error_code);
          FND_MESSAGE.set_token('DATE', X_date2);
          FND_MSG_PUB.add;
          warnings := warnings + 1;
        end if;
      end if;

    end if;

    if ( task%isopen ) then
      close task;
    end if;

    if ( base_task%isopen ) then
      close base_task;
    end if;

  end if; -- end of validate task
  end if; -- end of validate project
  end if; -- end of Project or Seiban

  --
  -- Calling extension routine for any custom validations
  --
  retsts := PJM_PROJECT_EXT.validate_proj_references
            ( X_inventory_org_id    => X_inventory_org_id
            , X_operating_unit      => L_operating_unit
            , X_project_id          => X_project_id
            , X_task_id             => X_task_id
            , X_date1               => X_date1
            , X_date2               => X_date2
            , X_calling_function    => X_calling_function
            , X_error_code          => X_error_code
            );

  if ( retsts = G_VALIDATE_FAILURE ) then
    failures := failures + 1;
  elsif ( retsts = G_VALIDATE_WARNING ) then
    warnings := warnings + 1;
  end if;

  if ( failures > 0 ) then
    raise VALIDATE_FAILURE;
  elsif ( warnings > 0 ) then
    raise VALIDATE_WARNING;
  else
    return ( G_VALIDATE_SUCCESS );
  end if;

exception
when VALIDATE_FAILURE then
  msgdata := '';
  msgcount := FND_MSG_PUB.count_msg;
  for i in 1..msgcount loop
    msgdata := msgdata ||
               i || '. ' ||
               fnd_msg_pub.get( p_msg_index => i
                              , p_encoded   => FND_API.G_FALSE ) ||
               fnd_global.newline;
  end loop;
  fnd_message.set_name('PJM' , 'GEN-PROJ REF FAILURE');
  fnd_message.set_token('ERRORTEXT' , msgdata);
  return ( G_VALIDATE_FAILURE );

when VALIDATE_WARNING then
  msgdata := '';
  msgcount := fnd_msg_pub.count_msg;
  for i in 1..msgcount loop
    msgdata := msgdata ||
               i || '. ' ||
               fnd_msg_pub.get( p_msg_index => i
                              , p_encoded   => FND_API.G_FALSE ) ||
               fnd_global.newline;
  end loop;
  fnd_message.set_name('PJM' , 'GEN-PROJ REF WARNING');
  fnd_message.set_token('ERRORTEXT' , msgdata);
  return ( G_VALIDATE_WARNING );

when others then
  if fnd_msg_pub.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
    fnd_msg_pub.add_exc_msg( p_pkg_name => 'PJM_PROJECT'
                           , p_procedure_name => 'VALIDATE_PROJ_REFERENCES' );
  end if;
  return ( G_VALIDATE_FAILURE );
end validate_proj_references;


end PJM_PROJECT;

/
