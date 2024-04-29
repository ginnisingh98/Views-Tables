--------------------------------------------------------
--  DDL for Package Body PQH_BDGT_REALLOC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT_REALLOC_UTILITY" as
/* $Header: pqbreutl.pkb 120.2 2006/02/03 14:18:03 deenath noship $ */

g_package  Varchar2(30) := ' pqh_bdgt_realloc_utility.';
g_warning  Varchar2(30);
--
---------------------------get_entity_name-----------------------------
--

FUNCTION get_entity_name
(
 p_entity_id              IN    pqh_bdgt_pool_realloctions.entity_id%TYPE,
 p_entity_type            IN    pqh_budget_pools.entity_type%TYPE
)
RETURN  VARCHAR IS
/*
  This function will return the Entity Name.
*/

BEGIN

   If p_entity_type = 'POSITION' then
      return(hr_general. DECODE_POSITION_LATEST_NAME (p_entity_id ));
   elsif p_entity_type = 'JOB' then
     return(hr_general.DECODE_JOB(p_entity_id));
   elsif p_entity_type = 'ORGANIZATION' then
     return(hr_general.DECODE_ORGANIZATION(p_entity_id ));
   elsif p_entity_type = 'GRADE' then
     return(hr_general.DECODE_GRADE(p_entity_id ));
   end if;
END get_entity_name;
--
---------------------------GET_PRD_REALLOC_RESERVED_AMT-----------------------------
--

FUNCTION GET_PRD_REALLOC_RESERVED_AMT
(
 p_budget_period_id       IN    pqh_budget_periods.budget_period_id%TYPE,
 p_budget_unit_id         IN    pqh_budgets.budget_unit1_id%TYPE,
 p_transaction_type       IN   pqh_bdgt_pool_realloctions.transaction_type%TYPE DEFAULT 'DD',
 p_approval_status        IN    varchar2,
 p_amount_type            IN    varchar2 ,
 p_entity_type            IN   varchar2,
 p_entity_id              IN   NUMBER,
 p_start_date             IN   DATE,
 p_end_date               IN   DATE
)
RETURN  NUMBER IS
/*

  This function will return Already Donated or Unapproved Donations amount for
  Or Received amount a given budged period.
  For Already Donated : Approval Type is 'A'
  For Unapproved Donations  : Approval Type is 'P'
  Default for Approval type is 'P'
Transaction Type :
==================
DD - Donor Details
RD - Receiver Details
Default for Transaction Type is 'DD'

Amount Type :
==============
R - Reallocation Amount
RV - Reserved Amount
*/
l_realloc_amt NUMBER := 0;
l_reserved_amt NUMBER := 0;
/*for donors amount to be picked based on budget period_id */
CURSOR csr_donor_amt(p_approval_status IN Varchar2) IS
  SELECT NVL(sum(trnxamt.reallocation_amt),0), NVL(sum(trnxamt.reserved_amt),0)
  FROM   pqh_budget_pools fld,
         pqh_budget_pools trnx,
         pqh_bdgt_pool_realloctions trnxdtl,
         pqh_bdgt_pool_realloctions trnxamt
  WHERE  fld.pool_id = trnx.parent_pool_id
   AND   fld.approval_status=p_approval_status
   AND   fld.budget_unit_id = p_budget_unit_id
   AND   fld.entity_type = p_entity_type
   AND   trnx.pool_id = trnxdtl.pool_id
   AND   trnxdtl.reallocation_id = trnxamt.txn_detail_id
   AND   trnxamt.budget_period_id = p_budget_period_id
   AND   trnxamt.transaction_type = p_transaction_type;

/* for receivers the amount to be picked up based on entity/start date/end date */
CURSOR csr_receiver_amt(p_approval_status IN varchar2) IS
  SELECT NVL(sum(trnxamt.reallocation_amt),0), NVL(sum(trnxamt.reserved_amt),0)
  FROM   pqh_budget_pools fld,
         pqh_budget_pools trnx,
         pqh_bdgt_pool_realloctions trnxdtl,
         pqh_bdgt_pool_realloctions trnxamt
  WHERE  fld.pool_id = trnx.parent_pool_id
   AND   fld.budget_unit_id = p_budget_unit_id
   AND   fld.entity_type = p_entity_type
   AND   trnx.pool_id = trnxdtl.pool_id
   AND   fld.approval_status = p_approval_status
   AND   trnxdtl.reallocation_id = trnxamt.txn_detail_id
   AND   trnxamt.transaction_type = p_transaction_type
   AND   trnxamt.entity_id = p_entity_id
   AND   NVL(trnxamt.start_date,to_date('31/12/4712','dd/mm/RRRR')) BETWEEN p_start_date and p_end_date
   AND   NVL(trnxamt.end_date,to_date('31/12/4712','dd/mm/RRRR')) BETWEEN p_start_date and p_end_date;

BEGIN
  -- get unit amt
  IF p_amount_type = 'RV' THEN
    IF p_transaction_type = 'DD' THEN
      OPEN csr_donor_amt('A');
      FETCH csr_donor_amt INTO l_realloc_amt, l_reserved_amt;
      CLOSE csr_donor_amt;
    ELSIF p_transaction_type = 'RD' THEN
      OPEN csr_receiver_amt('A');
      FETCH csr_receiver_amt INTO l_realloc_amt, l_reserved_amt;
      CLOSE csr_receiver_amt;
    END IF;
  ELSIF p_amount_type = 'R' THEN
    IF p_transaction_type = 'DD' THEN
      OPEN csr_donor_amt(p_approval_status);
      FETCH csr_donor_amt INTO l_realloc_amt, l_reserved_amt;
      CLOSE csr_donor_amt;
    ELSIF p_transaction_type = 'RD' THEN
      OPEN csr_receiver_amt(p_approval_status);
      FETCH csr_receiver_amt INTO l_realloc_amt, l_reserved_amt;
      CLOSE csr_receiver_amt;
    END IF;
  END IF;
  If p_amount_type = 'R' then
     RETURN l_realloc_amt;
  Elsif p_amount_type = 'RV' then
     RETURN l_reserved_amt;
  End if;

EXCEPTION
  WHEN OTHERS THEN
    l_realloc_amt := 0;
    l_reserved_amt := 0;
    return(0);
END GET_PRD_REALLOC_RESERVED_AMT;

--
---------------------------GET_DTL_REALLOC_RESERVED_AMT-----------------------------
--

FUNCTION GET_DTL_REALLOC_RESERVED_AMT
(
 p_budget_detail_id       IN    pqh_budget_details.budget_detail_id%TYPE,
 p_budget_unit_id         IN    pqh_budgets.budget_unit1_id%TYPE,
 p_transaction_type       IN   pqh_bdgt_pool_realloctions.transaction_type%TYPE DEFAULT 'DD',
 p_approval_status        IN    varchar2,
 p_amount_type            IN    varchar2,
 p_entity_type            IN    varchar2,
 p_entity_id              IN    number,
 p_start_date             IN    date,
 p_end_date               IN    date
)
RETURN  NUMBER IS
/*

  This function will return Already Donated or Unapproved Donations amount for
  Or Received amount of a given budget detail.
  For Already Donated : Approval Type is 'A'
  For Unapproved Donations  : Approval Type is 'P'
  Default for Approval type is 'P'
Transaction Type :
==================
DD - Donor Details
RD - Receiver Details
Default for Transaction Type is 'DD'

Amount Type :
==============
R - Reallocation Amount
RV - Reserved Amount
*/
l_period_id NUMBER;

l_budget_unit_id NUMBER := p_budget_unit_id;
l_transaction_type VARCHAR2(2) := p_transaction_type;
l_approval_status VARCHAR2(1) := p_approval_status;
l_amount_type VARCHAR2(2) := p_amount_type;


CURSOR csr_donor_amt(p_approval_status in varchar2) IS
  SELECT  NVL(SUM(trnxamt.reallocation_amt),0), NVL(SUM(trnxamt.reserved_amt),0)
  FROM    pqh_budget_pools fld,
          pqh_budget_pools trnx,
          pqh_bdgt_pool_realloctions trnxdtl,
          pqh_bdgt_pool_realloctions trnxamt
  WHERE   fld.budget_unit_id = p_budget_unit_id
    AND   fld.entity_type = p_entity_type
    AND   fld.approval_status = p_approval_status
    AND   fld.pool_id = trnx.parent_pool_id
    AND   trnx.pool_id = trnxdtl.pool_id
    AND   trnxdtl.budget_detail_id = p_budget_detail_id
    AND   trnxamt.transaction_type = 'DD'
    AND   trnxdtl.reallocation_id = trnxamt.txn_detail_id;

CURSOR csr_receiver_amt(p_approval_status in varchar2) IS
  SELECT  NVL(SUM(trnxamt.reallocation_amt),0), NVL(SUM(trnxamt.reserved_amt),0)
  FROM    pqh_budget_pools fld,
          pqh_budget_pools trnx,
          pqh_bdgt_pool_realloctions trnxdtl,
          pqh_bdgt_pool_realloctions trnxamt
  WHERE   fld.budget_unit_id = p_budget_unit_id
    AND   fld.entity_type = p_entity_type
    AND   fld.approval_status = p_approval_status
    AND   fld.pool_id = trnx.parent_pool_id
    AND   trnx.pool_id = trnxdtl.pool_id
    AND   trnxdtl.reallocation_id = trnxamt.txn_detail_id
    AND   trnxdtl.entity_id = p_entity_id
    AND   trnxamt.transaction_type = 'RD'
    AND   NVL(trnxamt.start_date,TO_DATE('31/12/4712','dd/mm/RRRR')) BETWEEN p_start_date and p_end_date
    AND   NVL(trnxamt.end_date,TO_DATE('31/12/4712','dd/mm/RRRR')) BETWEEN p_start_date and p_end_date;
 l_reserved_amt NUMBER := 0;
 l_realloc_amt  NUMBER := 0;
BEGIN
 IF p_transaction_type = 'DD' THEN
    IF p_amount_type = 'RV' THEN
       OPEN csr_donor_amt('A');
       FETCH csr_donor_amt INTO l_realloc_amt,l_reserved_amt;
       CLOSE csr_donor_amt;
    ELSE
       OPEN csr_donor_amt(p_approval_status);
       FETCH csr_donor_amt INTO l_realloc_amt,l_reserved_amt;
       CLOSE csr_donor_amt;
    END IF;
 ELSIF p_transaction_type = 'RD' THEN
   IF p_amount_type = 'RV' THEN
     OPEN csr_receiver_amt('A');
     FETCH csr_receiver_amt INTO l_realloc_amt, l_reserved_amt;
     CLOSE csr_receiver_amt;
   ELSE
     OPEN csr_receiver_amt(p_approval_status);
     FETCH csr_receiver_amt INTO l_realloc_amt, l_reserved_amt;
     CLOSE csr_receiver_amt;
   END IF;
 END IF;
  If p_amount_type = 'R' then
     RETURN l_realloc_amt;
  Elsif p_amount_type = 'RV' then
     RETURN l_reserved_amt;
  End if;
EXCEPTION
 WHEN OTHERS THEN

   return (0);

end GET_DTL_REALLOC_RESERVED_AMT;

--
---------------------------GET_TRNX_LEVEL_TRANS_AMT-----------------------------
--


FUNCTION GET_TRNX_LEVEL_TRANS_AMT
(
 p_transaction_id         IN    pqh_bdgt_pool_realloctions.reallocation_id%TYPE,
 p_txn_amt_balance_flag    IN    varchar2
) RETURN  NUMBER IS

/*
a) Txn Aount  is donor amount or receiver amount whichever is higher. for a balanced txn it will be same.
b) Txn Balancce is donor amt - rcvr amt

This function returns Transaction/Reallocation Amount and Transaction Balance Amount for a given Transation Id.


Txn Amt Balance_flag :
==========================
TA - Transaction Amount
TB - Transaction Balance


*/
CURSOR csr_tranaction_amt (p_transaction_type in varchar)
IS
Select nvl(sum(trnxamt.reallocation_amt),0)
From pqh_bdgt_pool_realloctions trnxamt,
pqh_bdgt_pool_realloctions trnxdtl
where trnxamt.txn_detail_id = trnxdtl.reallocation_id
and  trnxdtl.pool_id= p_transaction_id
and  trnxamt.transaction_type = p_transaction_type;

l_donor_txn_amt number;
l_receiver_txn_amt number;
l_txn_amt number;

begin

Open csr_tranaction_amt(p_transaction_type => 'DD');
fetch csr_tranaction_amt into l_donor_txn_amt;
close csr_tranaction_amt;

Open csr_tranaction_amt(p_transaction_type => 'RD');
fetch csr_tranaction_amt into l_receiver_txn_amt;
close csr_tranaction_amt;

If p_txn_amt_balance_flag = 'TA' then
   if l_donor_txn_amt > l_receiver_txn_amt then
      return (l_donor_txn_amt);
   else
      return (l_receiver_txn_amt);
   end if;
End If;

If p_txn_amt_balance_flag = 'TB' then
         return ((l_donor_txn_amt)-(l_receiver_txn_amt));
End If;

EXCEPTION
  WHEN OTHERS THEN
    l_receiver_txn_amt := 0;
    l_donor_txn_amt := 0;
    return l_receiver_txn_amt;
End GET_TRNX_LEVEL_TRANS_AMT;
--
---------------------------GET_FOLDER_LEVEL_TRANS_AMT-----------------------------
--

FUNCTION GET_FOLDER_LEVEL_TRANS_AMT
(
 p_folder_id             IN    pqh_budget_pools.pool_id%TYPE
) RETURN  NUMBER IS

/* This function returns Transaction Amount for a given Folder Id */

CURSOR csr_transaction_ids
IS
Select pool_id
From   pqh_budget_pools
Where  parent_pool_id= p_folder_id;

l_transaction_id number;
l_trans_amt number :=0;
l_folder_amt number:=0;

Begin

open csr_transaction_ids;
loop
  fetch csr_transaction_ids into l_transaction_id;
  exit when csr_transaction_ids%notfound;
  if l_transaction_id is not null then
    l_trans_amt := pqh_bdgt_realloc_utility.GET_TRNX_LEVEL_TRANS_AMT
                     (p_transaction_id => l_transaction_id
                     ,p_txn_amt_balance_flag => 'TA');
    l_folder_amt := l_folder_amt + l_trans_amt;

  end if;
 end loop;
 close csr_transaction_ids;
 return l_folder_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_folder_amt := 0;
    return(l_folder_amt);

End GET_FOLDER_LEVEL_TRANS_AMT;

FUNCTION GET_TRNX_DNR_REVR_COUNT
(
 p_transaction_id             IN    pqh_bdgt_pool_realloctions.reallocation_id%TYPE,
 p_transaction_type       IN    pqh_bdgt_pool_realloctions.transaction_type%TYPE
) RETURN  NUMBER IS

/*
This function retuns the number of Donors/Receivers for a given Transaction
Transaction Type :
====================
D - Donor
R - Receiver

*/

CURSOR csr_dnr_revr_count
IS
Select count(*)
From   pqh_bdgt_pool_realloctions
Where  pool_id = p_transaction_id
And    transaction_type = p_transaction_type;

l_count number;

Begin

Open csr_dnr_revr_count;
fetch csr_dnr_revr_count into l_count;
close csr_dnr_revr_count;

return (nvl(l_count,0) );

EXCEPTION
  WHEN OTHERS THEN
    l_count := 0;
    return l_count;

End GET_TRNX_DNR_REVR_COUNT;
--
---------------------------CHK_RECV_EXISTS-----------------------------
--
PROCEDURE CHK_RECV_EXISTS
(
	p_trans_id	IN	pqh_bdgt_pool_realloctions.pool_id%TYPE,
	p_entity_id	IN	pqh_bdgt_pool_realloctions.entity_id%TYPE,
	p_detail_id	OUT NOCOPY	pqh_bdgt_pool_realloctions.reallocation_id%TYPE
)
/*
This function checks whether a receiver exists in a Transaction or not
If it exists then it returns the reallocation_id else returns -1

*/
IS
CURSOR csr_trnx_det
IS
select transaction_id,entity_id,txn_detail_id
from pqh_realloc_txn_details_v
where transaction_id = p_trans_id
and entity_id =p_entity_id
and transaction_type = 'R';
csr_trnx_det_rec csr_trnx_det%rowtype;

BEGIN

OPEN csr_trnx_det;

FETCH csr_trnx_det into csr_trnx_det_rec;
IF(csr_trnx_det%rowcount=0) THEN
p_detail_id := -1;
ELSE
p_detail_id := csr_trnx_det_rec.txn_detail_id;
END IF;
CLOSE csr_trnx_det;

EXCEPTION
  WHEN OTHERS THEN
p_detail_id := 0;

End CHK_RECV_EXISTS;
--

FUNCTION CHK_APPROVED_FOLDER
(
 p_budget_version_id      IN    pqh_budget_pools.budget_version_id%TYPE,
 p_budget_unit_id         IN    pqh_budget_pools.budget_unit_id%TYPE,
 p_entity_type            IN    pqh_budget_pools.entity_type%TYPE,
 p_approval_status        IN    pqh_budget_pools.approval_status%Type) RETURN  NUMBER IS

/*
Approval Status :
================
A - Approved
P - Pending

This function returns the Budget Folder is Approved or not for a given
Budget Version Id, Budget Unit Id, Entity Type ,Approval Status*/

CURSOR csr_approved_folder
IS
Select count(pool_id)
From   pqh_budget_pools
Where  budget_version_id = p_budget_version_id
And    budget_unit_id = p_budget_unit_id
And    entity_type = p_entity_type
And    approval_status  = p_approval_status;

l_count number;

Begin
   Open csr_approved_folder;
   Fetch csr_approved_folder into l_count;
   Close csr_approved_folder;

   If l_count <> 0  Then
        return 1;
   Else
        return 0;
   End If;

EXCEPTION
  WHEN OTHERS THEN
     return 0;
End CHK_APPROVED_FOLDER;
---------------------------GET_TRNX_LEVEL_RESERVED_AMT-----------------------------
--
FUNCTION GET_TRNX_LEVEL_RESERVED_AMT
(
 p_transaction_id         IN    pqh_bdgt_pool_realloctions.reallocation_id%TYPE,
 p_transaction_type       IN    pqh_bdgt_pool_realloctions.transaction_type%TYPE DEFAULT 'DD'
) RETURN  NUMBER IS

/*
This function returns Transaction/Reallocation Amount for a given Transation Id.
Transaction Type :
====================
DD - Donor Details
RD - Receiver Details

Default is DD
*/
CURSOR csr_tranaction_amt
IS
Select nvl(sum(trnxamt.reserved_amt),0)
From pqh_bdgt_pool_realloctions trnxamt,
pqh_bdgt_pool_realloctions trnxdtl
where trnxamt.txn_detail_id = trnxdtl.reallocation_id
and  trnxdtl.pool_id= p_transaction_id
and  trnxamt.transaction_type = p_transaction_type;

l_trans_amt number;

begin

Open csr_tranaction_amt;
fetch csr_tranaction_amt into l_trans_amt;
close csr_tranaction_amt;

return (l_trans_amt );

EXCEPTION
  WHEN OTHERS THEN
    l_trans_amt := 0;
    return l_trans_amt;
End GET_TRNX_LEVEL_RESERVED_AMT;
--
FUNCTION GET_LOCATION_CODE
(
 p_entity_code		IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_organization_id	IN    pqh_budget_details.organization_id%TYPE,
 p_business_group_id    IN    hr_organization_units_v.business_group_id%TYPE
) RETURN  VARCHAR
IS
l_location_code VARCHAR2(30);
BEGIN
 IF(p_entity_code = 'POSITION' OR p_entity_code = 'ORGANIZATION') then
	select location_code
	into l_location_code
	from hr_organization_units_v
	where organization_id = p_organization_id;
  ELSE
       select location_code
       into l_location_code
       from hr_organization_units_v
       where organization_id= p_business_group_id;
  END IF;
  RETURN l_location_code;
EXCEPTION
WHEN OTHERS THEN
 l_location_code := null;
 RETURN l_location_code;
END GET_LOCATION_CODE;

--
PROCEDURE APP_NEXT_USER
(p_trans_id              in pqh_routing_history.transaction_id%type,
p_tran_cat_id           in pqh_transaction_categories.transaction_category_id%type,
p_cur_user_id           in out nocopy fnd_user.user_id%type,
p_cur_user_name         in out nocopy fnd_user.user_name%type,
p_user_active_role_id   in out nocopy pqh_roles.role_id%type,
p_user_active_role_name in out nocopy pqh_roles.role_name%type,
p_routing_category_id      out nocopy pqh_routing_categories.routing_category_id%type,
p_member_cd                out nocopy pqh_transaction_categories.member_cd%type,
p_routing_list_id          out nocopy pqh_routing_lists.routing_list_id%type,
p_member_role_id           out nocopy pqh_roles.role_id%type,
p_member_user_id           out nocopy fnd_user.user_id%type,
p_person_id                out nocopy fnd_user.employee_id%type,
p_member_id                out nocopy pqh_routing_list_members.routing_list_member_id%type,
p_position_id              out nocopy pqh_position_transactions.position_id%type,
p_cur_person_id            out nocopy fnd_user.employee_id%type,
p_cur_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
p_cur_position_id          out nocopy pqh_position_transactions.position_id%type,
p_pos_str_ver_id           out nocopy pqh_routing_history.pos_structure_version_id%type,
p_assignment_id            out nocopy per_assignments_f.assignment_id%type,
p_cur_assignment_id        out nocopy per_assignments_f.assignment_id%type,
p_next_user                out nocopy varchar2,
p_next_user_display        out nocopy varchar2,
p_status_flag              out nocopy number,
p_can_approve              out nocopy number)
IS
l_can_approve         	BOOLEAN;
l_old_member_cd		varchar2(30);
l_routing_history_id	NUMBER;
l_member_id		NUMBER;
l_person_id		NUMBER;
l_old_member_id		NUMBER;
l_old_routing_list_id	NUMBER;
l_position_id		NUMBER;
l_old_position_id	NUMBER;
l_pos_str_id		NUMBER;
l_old_pos_str_id	NUMBER;
l_old_pos_str_ver_id	NUMBER;
l_assignment_id		NUMBER;
l_old_assignment_id	NUMBER;
l_history_flag		BOOLEAN;
l_range_name		VARCHAR2(80);
l_proc varchar2(61) := 'app_next_user';
BEGIN
hr_utility.set_location('inside'||l_proc,10);
pqh_workflow.applicable_next_user
             (p_trans_id               => p_trans_id
              ,p_tran_cat_id           => p_tran_cat_id
              ,p_cur_user_id           => p_cur_user_id
              ,p_cur_user_name         => p_cur_user_name
              ,p_user_active_role_id   => p_user_active_role_id
              ,p_user_active_role_name => p_user_active_role_name
              ,p_routing_category_id   => p_routing_category_id
              ,p_member_cd             => p_member_cd
              ,p_old_member_cd         => l_old_member_cd
              ,p_routing_history_id    => l_routing_history_id
              ,p_member_id             => p_member_id
              ,p_person_id             => p_person_id
              ,p_old_member_id         => l_old_member_id
              ,p_routing_list_id       => p_routing_list_id
              ,p_old_routing_list_id   => l_old_routing_list_id
              ,p_member_role_id        => p_member_role_id
              ,p_member_user_id        => p_member_user_id
              ,p_cur_person_id         => p_cur_person_id
              ,p_cur_member_id         => p_cur_member_id
              ,p_position_id           => p_position_id
              ,p_old_position_id       => l_old_position_id
              ,p_cur_position_id       => p_cur_position_id
              ,p_pos_str_id            => l_pos_str_id
              ,p_old_pos_str_id        => l_old_pos_str_id
              ,p_pos_str_ver_id        => p_pos_str_ver_id
              ,p_old_pos_str_ver_id    => l_old_pos_str_ver_id
              ,p_assignment_id         => p_assignment_id
              ,p_cur_assignment_id     => p_cur_assignment_id
              ,p_old_assignment_id     => l_old_assignment_id
              ,p_status_flag           => p_status_flag
              ,p_history_flag          => l_history_flag
              ,p_range_name            => l_range_name
              ,p_can_approve           => l_can_approve);
   hr_utility.set_location('status returned is'||p_status_flag,20);
   if nvl(p_status_flag,0) <> 0 then
      hr_utility.set_location('error returned',25);
   else
      hr_utility.set_location('got the next user ',30);
      if(l_can_approve) then
         p_can_approve:=0;
         hr_utility.set_location('approver yes ',35);
      else
         p_can_approve:=1;
         hr_utility.set_location('approver no',40);
      end if;
      hr_utility.set_location('getting user name',50);
      hr_utility.set_location('member_cd is '||p_member_cd,60);
      hr_utility.set_location('position_id is '||p_position_id,62);
      hr_utility.set_location('assignment_id is '||p_assignment_id,64);
      hr_utility.set_location('user_id is '||p_member_user_id,66);
      hr_utility.set_location('role_id is '||p_member_role_id,68);
      FND_NEXT_USER(p_member_cd         => p_member_cd,
                    p_position_id       => p_position_id,
                    p_assignment_id     => p_assignment_id,
                    p_member_role_id    => p_member_role_id,
                    p_member_user_id    => p_member_user_id,
                    p_next_name_display => p_next_user_display,
                    p_next_name	        => p_next_user);
      hr_utility.set_location('user_name is '||p_next_user,70);
      hr_utility.set_location('display_name is '||p_next_user_display,75);
   end if;
END APP_NEXT_USER;

procedure get_next_user(p_member_cd           in pqh_transaction_categories.member_cd%type,
			p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                        p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
			p_trans_id            in pqh_routing_history.transaction_id%type,
			p_cur_assignment_id   in per_assignments_f.assignment_id%type,
			p_cur_member_id       in pqh_routing_list_members.routing_list_member_id%type,
			p_routing_list_id     in pqh_routing_categories.routing_list_id%type,
			p_cur_position_id     in pqh_position_transactions.position_id%type,
			p_pos_str_ver_id      in per_pos_structure_elements.pos_structure_version_id%type,
			p_next_position_id       out nocopy pqh_position_transactions.position_id%type,
			p_next_member_id         out nocopy pqh_routing_list_members.routing_list_member_id%type,
                        p_next_role_id           out nocopy number,
                        p_next_user_id           out nocopy number,
			p_next_assignment_id     out nocopy per_assignments_f.assignment_id%type,
			p_status_flag            out nocopy number,
                        p_next_user              out nocopy varchar2,
                        p_next_user_display      out nocopy varchar2) is
begin
   pqh_workflow.next_applicable
                  (p_member_cd           => p_member_cd,
	  	   p_routing_category_id => p_routing_category_id,
                   p_tran_cat_id         => p_tran_cat_id,
		   p_trans_id            => p_trans_id,
		   p_cur_assignment_id   => p_cur_assignment_id,
		   p_cur_member_id       => p_cur_member_id,
		   p_routing_list_id     => p_routing_list_id,
		   p_cur_position_id     => p_cur_position_id,
		   p_pos_str_ver_id      => p_pos_str_ver_id,
		   p_next_position_id    => p_next_position_id,
		   p_next_member_id      => p_next_member_id,
                   p_next_role_id        => p_next_role_id,
                   p_next_user_id        => p_next_user_id,
		   p_next_assignment_id  => p_next_assignment_id,
		   p_status_flag         => p_status_flag);
   hr_utility.set_location('getting user name',50);
   hr_utility.set_location('member_cd is '||p_member_cd,60);
   hr_utility.set_location('position_id is '||p_next_position_id,62);
   hr_utility.set_location('assignment_id is '||p_next_assignment_id,64);
   hr_utility.set_location('user_id is '||p_next_user_id,66);
   hr_utility.set_location('role_id is '||p_next_role_id,68);
   FND_NEXT_USER(p_member_cd         => p_member_cd,
                 p_position_id       => p_next_position_id,
                 p_assignment_id     => p_next_assignment_id,
                 p_member_role_id    => p_next_role_id,
                 p_member_user_id    => p_next_user_id,
                 p_next_name_display => p_next_user_display,
                 p_next_name	     => p_next_user);
   hr_utility.set_location('user_name is '||p_next_user,70);
end get_next_user;

PROCEDURE FND_NEXT_USER(p_member_cd         IN pqh_transaction_categories.member_cd%type,
                        p_position_id       IN pqh_position_transactions.position_id%type,
                        p_assignment_id     IN per_assignments_f.assignment_id%type,
                        p_member_role_id    IN pqh_roles.role_id%type,
                        p_member_user_id    IN fnd_user.user_id%type,
                        p_next_name         OUT NOCOPY VARCHAR,
                        p_next_name_display OUT NOCOPY VARCHAR) is
   l_next_name VARCHAR2(240);
   l_person_id NUMBER;
begin
IF(p_member_cd = 'R') THEN
   IF(p_member_user_id is NOT null) THEN
      select user_name
      into p_next_name
      from fnd_user
      where user_id=p_member_user_id;
      hr_utility.set_location('user_name is '||p_next_name,10);
      l_next_name := hr_general.decode_lookup(p_lookup_type => 'PQH_BPR_ROUTING',
                                              p_lookup_code => 'USER');
      hr_utility.set_location('prefix is '||l_next_name,20);
      p_next_name_display := l_next_name ||':'||p_next_name ;
      hr_utility.set_location('name is '||p_next_name_display,30);
   ELSIF p_member_role_id is not null then
      select role_name
      into p_next_name
      from pqh_roles
      where role_id= p_member_role_id;
      hr_utility.set_location('user_name is '||p_next_name,40);
      l_next_name := hr_general.decode_lookup(p_lookup_type => 'PQH_BPR_ROUTING',
                                              p_lookup_code => 'ROLE');
      hr_utility.set_location('prefix is '||l_next_name,50);
      p_next_name_display := l_next_name ||':'||p_next_name ;
      p_next_name         := 'PQH_ROLE:'||p_member_role_id;
      hr_utility.set_location('name is '||p_next_name_display,60);
   else
      hr_utility.set_location('member_cd R but null values',70);
      p_next_name := null;
      p_next_name_display := null;
   END IF;
ELSIF (p_member_cd = 'P') THEN
   select hr_general.DECODE_POSITION_LATEST_NAME (p_position_id)
   into p_next_name from dual;
   hr_utility.set_location('user_name is '||p_next_name,80);
   l_next_name := hr_general.decode_lookup(p_lookup_type => 'PQH_BPR_ROUTING',
                                           p_lookup_code => 'POSITION');
   hr_utility.set_location('prefix is '||l_next_name,90);
   p_next_name_display := l_next_name ||':'||p_next_name ;
   p_next_name := 'POS:'||p_position_id;
   hr_utility.set_location('name is '||p_next_name_display,100);
ELSIF (p_member_cd = 'S') THEN
   select person_id into l_person_id
   from per_assignments
   where assignment_id  = p_assignment_id;
   hr_utility.set_location('person_id is '||l_person_id,110);
   select user_name
   into p_next_name
   from fnd_user
   where employee_id=l_person_id;
   hr_utility.set_location('user_name is '||p_next_name,120);
   l_next_name := hr_general.decode_lookup(p_lookup_type => 'PQH_BPR_ROUTING',
                                           p_lookup_code => 'USER');
   hr_utility.set_location('prefix is '||l_next_name,130);
   p_next_name_display := l_next_name ||':'||p_next_name ;
   hr_utility.set_location('name is '||p_next_name_display,140);
ELSE
   hr_utility.set_location('invalid member_cd',150);
   p_next_name := null;
   p_next_name_display := null;
END IF;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('data issues',420);
      p_next_name := null;
      p_next_name_display := null;
END FND_NEXT_USER;

-- ----------------------------------------------------------------------------
-- |------------------------< apply_transaction >------------------------|
-- ----------------------------------------------------------------------------

function apply_transaction
(  p_transaction_id    in  NUMBER,
   p_validate_only              in varchar2 default 'NO'
) return varchar2 is

 l_proc                      varchar2(72) := g_package||'apply_transaction';
 l_status   varchar2(30);
 l_return   varchar2(30);
 l_transaction_category_id NUMBER;

 Cursor csr_pool_dtls
 IS  SELECT *
     FROM   pqh_budget_pools
     WHERE  pool_id = p_transaction_id;
 l_pool_rec  csr_pool_dtls%ROWTYPE;
BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
--calling routine for enabling multi-message detection --kgowripe
   hr_multi_message.enable_message_list;
--
   OPEN csr_pool_dtls;
   FETCH csr_pool_dtls INTO  l_pool_rec;
   CLOSE csr_pool_dtls;
   -- Added by krmahade for Bug#3036405
   l_transaction_category_id := l_pool_rec.wf_transaction_category_id;
   -- End krmahade
   hr_utility.set_location('txn_cat is '||l_transaction_category_id||l_proc,12);
   --Before Applying a Budget Reallocation Transaction, apply all the Business Rules
   pqh_cbr_engine.apply_rules(p_transaction_type => 'REALLOCATION'
                             ,p_transaction_id => p_transaction_id
                             ,p_business_group_id => l_pool_rec.business_group_id
                             ,p_effective_date => hr_general.effective_date
                             ,p_status_flag => l_status);
   hr_utility.set_location('status returned is '||l_status||l_proc,20);

   IF NVL(l_status,'S') <> 'E'and p_validate_only = 'NO' THEN
      hr_utility.set_location('for folder approval '||l_proc,22);
      pqh_budget_pools_api.update_reallocation_folder(p_effective_date=> hr_general.effective_date
                                                     ,p_folder_id => p_transaction_id
                                                     ,p_object_version_number=>l_pool_rec.object_version_number
                                                     ,p_business_group_id => l_pool_rec.business_group_id
                                                     ,p_approval_status=> 'A'
                                                     ,p_wf_transaction_category_id => l_pool_rec.wf_transaction_category_id );
      hr_utility.set_location('folder approved '||l_proc,26);
  ELSIF l_status = 'E' THEN
      hr_utility.set_location('error encountered '||l_proc,28);
      l_return := 'FAILURE';
      fnd_message.set_name(8302,'PQH_CBR_FAILED_ERROR');
      fnd_message.raise_error;
  END IF;
  -- Addd by KGOWRIPE for fixing bug# 2896852
  IF NVL(l_status,'S') = 'W'  THEN
      l_return := 'WARNING';
      hr_utility.set_location('Warning at '||l_proc,29);
      /* commented by mvankada for fixing the bug : 293577

      pqh_wf.set_apply_error(p_transaction_category_id => l_transaction_category_id,
                             p_transaction_id          => p_transaction_id,
                             p_apply_error_mesg        => 'PQH_BPR_WARNING',
                             p_apply_error_num         => 0);
       */
       g_warning := 'TRUE';
  ELSE
      l_return := 'SUCCESS';
  END IF;
-- end fix for 2896852
  hr_utility.set_location('Leaving '||l_proc,30);
  --
  RETURN l_return;
  Exception
--added by kgowripe
  when hr_multi_message.error_message_exist then
    Null;

When Others THEN

   IF SQLERRM IS NOT NULL THEN
     hr_utility.set_location('setting wf error '||l_proc,40);
     pqh_wf.set_apply_error(p_transaction_category_id => l_transaction_category_id,
                            p_transaction_id          => p_transaction_id,
                            p_apply_error_mesg        => SQLERRM,
                            p_apply_error_num         => SQLCODE);
     l_return := 'FAILURE';
   END IF;
        --
   hr_utility.set_location('Leaving '||l_proc,30);
   return l_return;
        --
End apply_transaction;

FUNCTION entity_id
( p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE,
p_entity_type    IN pqh_budgets.budgeted_entity_cd%TYPE
)RETURN NUMBER
IS
l_entity_id NUMBER :=0;
CURSOR csr_details
IS
select job_id,position_id,grade_id,organization_id
from pqh_budget_details
where budget_detail_id = p_budget_detail_id;
rec_details csr_details%ROWTYPE;
BEGIN
OPEN csr_details;
FETCH csr_details into rec_details;
   If p_entity_type = 'POSITION' then
	l_entity_id := rec_details.position_id;
   elsif p_entity_type = 'JOB' then
     l_entity_id := rec_details.job_id;
   elsif p_entity_type = 'ORGANIZATION' then
     l_entity_id := rec_details.organization_id;
   elsif p_entity_type = 'GRADE' then
     l_entity_id := rec_details.grade_id;
   else
     l_entity_id :=0;
   end if;
CLOSE csr_details;
	return l_entity_id;
EXCEPTION
  WHEN OTHERS THEN
  l_entity_id :=0;
  return l_entity_id;
END entity_id;

FUNCTION respond_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'respond_notification' ;
  l_folder_name       varchar2(2000);
  l_unit       varchar2(80);
  l_entity_desc varchar2(80);
  l_transaction_status  varchar2(100);
  cursor csr_pool_dtls is select name,
                                 hr_general.decode_lookup('PQH_BUDGET_ENTITY',ENTITY_TYPE),
                      hr_general.decode_shared_type(budget_unit_id),
                      hr_general.decode_lookup('PQH_REALLOC_TXN_STATUS',approval_status)
               from pqh_budget_pools
               where pool_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside respond notification'||l_proc,10);
  open csr_pool_dtls;
  fetch csr_pool_dtls into l_folder_name,l_entity_desc,l_unit,l_transaction_status;
  close csr_pool_dtls;
  hr_utility.set_location('pool dtls  fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_BPL_WF_RESPOND_NOTICE');
  hr_utility.set_message_token('FOLDER_NAME',l_folder_name);
  hr_utility.set_message_token('ENTITY',l_entity_desc);
  hr_utility.set_message_token('UNIT',l_unit);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_BPL_WF_RESPOND_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END respond_notification;

FUNCTION url_builder(p_transaction_id  in number) Return VARCHAR2 IS
 l_url   varchar2(1000);
 l_status  varchar2(30) := 'P';
 Cursor csr_folder_status IS
   SELECT business_group_id, NVL(approval_status,'P')
   FROM   pqh_budget_pools
  WHERE   pool_id = p_transaction_id;
 l_business_group_id Number(15);
 l_proc  varchar2(80) := g_package||'url_builder';
BEGIN
  hr_utility.set_location('Entering '||l_proc,10);
  OPEN csr_folder_status;
  FETCH csr_folder_status INTO l_business_group_id,l_status;
  CLOSE csr_folder_status;
  l_url := 'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pqh/budgetreallocation/webui/BprReallocPG'||'&'||'retainAM=Y'||'&'||'P_FolderId='||p_transaction_id||'&'||'fromNotify=Y'||'&'||'approvalStatusFlag='||l_status||'&'||'P_BGId='||l_business_group_id;
  hr_utility.set_location('URL '||substr(l_url,1,50),15);
  hr_utility.set_location('URL2 '||substr(l_url,51,100),15);
  hr_utility.set_location('Leaving '||l_proc,20);
  RETURN l_url;
END url_builder;
FUNCTION warning_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'warning_notification' ;
  l_folder_name       varchar2(2000);
  l_unit       varchar2(80);
  l_entity_desc varchar2(80);
  l_transaction_status  varchar2(100);
  cursor csr_pool_dtls is select name,
                                 hr_general.decode_lookup('PQH_BUDGET_ENTITY',ENTITY_TYPE),
                      hr_general.decode_shared_type(budget_unit_id),
                      hr_general.decode_lookup('PQH_REALLOC_TXN_STATUS',approval_status)
               from pqh_budget_pools
               where pool_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside warning notification'||l_proc,10);
  open csr_pool_dtls;
  fetch csr_pool_dtls into l_folder_name,l_entity_desc,l_unit,l_transaction_status;
  close csr_pool_dtls;
  hr_utility.set_location('pool dtls  fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_BPL_WF_WARN_NOTICE');
  hr_utility.set_message_token('FOLDER_NAME',l_folder_name);
  hr_utility.set_message_token('ENTITY',l_entity_desc);
  hr_utility.set_message_token('UNIT',l_unit);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_BPL_WF_WARN_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END warning_notification;
FUNCTION reject_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'reject_notification' ;
  l_folder_name       varchar2(2000);
  l_unit       varchar2(80);
  l_entity_desc varchar2(80);
  l_transaction_status  varchar2(100);
  cursor csr_pool_dtls is select name,
                                 hr_general.decode_lookup('PQH_BUDGET_ENTITY',ENTITY_TYPE),
                      hr_general.decode_shared_type(budget_unit_id),
                      hr_general.decode_lookup('PQH_REALLOC_TXN_STATUS',approval_status)
               from pqh_budget_pools
               where pool_id = p_transaction_id;
BEGIN
  hr_utility.set_location('Entering'||l_proc,10);
  open csr_pool_dtls;
  fetch csr_pool_dtls into l_folder_name,l_entity_desc,l_unit,l_transaction_status;
  close csr_pool_dtls;
  hr_utility.set_location('pool dtls  fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_BPL_WF_REJECT_NOTICE');
  hr_utility.set_message_token('FOLDER_NAME',l_folder_name);
  hr_utility.set_message_token('ENTITY',l_entity_desc);
  hr_utility.set_message_token('UNIT',l_unit);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  hr_utility.set_location('Leaving'||l_proc,10);
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_BPL_WF_REJECT_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
END reject_notification;
FUNCTION apply_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'apply_notification' ;
  l_folder_name       varchar2(2000);
  l_unit       varchar2(80);
  l_entity_desc varchar2(80);
  l_transaction_status  varchar2(100);
  cursor csr_pool_dtls is select name,
                                 hr_general.decode_lookup('PQH_BUDGET_ENTITY',ENTITY_TYPE),
                      hr_general.decode_shared_type(budget_unit_id),
                      hr_general.decode_lookup('PQH_REALLOC_TXN_STATUS',approval_status)
               from pqh_budget_pools
               where pool_id = p_transaction_id;
BEGIN
  hr_utility.set_location('Entering'||l_proc,10);
  open csr_pool_dtls;
  fetch csr_pool_dtls into l_folder_name,l_entity_desc,l_unit,l_transaction_status;
  close csr_pool_dtls;
  hr_utility.set_location('pool dtls  fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_BPL_WF_APPLY_NOTICE');
  hr_utility.set_message_token('FOLDER_NAME',l_folder_name);
  hr_utility.set_message_token('ENTITY',l_entity_desc);
  hr_utility.set_message_token('UNIT',l_unit);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  hr_utility.set_location('Leaving'||l_proc,10);
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_BPL_WF_APPLY_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
END apply_notification;

function reject_transaction
(  p_transaction_id    in  NUMBER,
   p_validate_only              in varchar2 default 'NO'
) return varchar2 is

 l_proc                      varchar2(72) := g_package||'reject_transaction';
 l_status   varchar2(30);
 l_return   varchar2(30);
 l_transaction_category_id NUMBER;
 l_validate boolean :=false;
--
 Cursor csr_pool_dtls
 IS  SELECT *
     FROM   pqh_budget_pools
     WHERE  pool_id = p_transaction_id;
 l_pool_rec  csr_pool_dtls%ROWTYPE;
BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
--added by kgowripe
hr_multi_message.enable_message_list;
--end changes by kgowripe
   OPEN csr_pool_dtls;
   FETCH csr_pool_dtls INTO  l_pool_rec;
   CLOSE csr_pool_dtls;

   if (p_validate_only = 'YES') then
     l_validate := true;
   end if;
  --
  pqh_budget_pools_api.update_reallocation_folder(p_effective_date=> hr_general.effective_date
                                                 ,p_folder_id => p_transaction_id
                                                 ,p_object_version_number=>l_pool_rec.object_version_number
                                                 ,p_business_group_id => l_pool_rec.business_group_id
                                                 ,p_approval_status=> 'R'
                                                 ,p_wf_transaction_category_id => l_pool_rec.wf_transaction_category_id
,p_validate => l_validate );

  l_return := 'SUCESS';
  hr_utility.set_location('Leaving '||l_proc,30);
  --
  RETURN l_return;
  Exception
--added by kgowripe
  when hr_multi_message.error_message_exist then
    Null;

  When Others THEN

   IF SQLERRM IS NOT NULL THEN
     pqh_wf.set_apply_error(p_transaction_category_id
                                                 => l_transaction_category_id,
                            p_transaction_id     => p_transaction_id,
                            p_apply_error_mesg   => SQLERRM,
                            p_apply_error_num    => SQLCODE);
     l_return := 'FAILURE';
   END IF;
        --
   hr_utility.set_location('Leaving '||l_proc,30);
   return l_return;
        --
End reject_transaction;



PROCEDURE notify_bgt_manager_users
(
 p_transaction_id number,
 p_transaction_name varchar2
) IS

/*
This procedure sends notifiction to all users having 'Budget Manager' as role type
*/
-- Added by mvankada
-- Bug : 2883516
-- added business_group_id is null condition
CURSOR csr_bgt_manager_rls(l_business_group_id IN number)
IS
Select  role_id,role_name
From pqh_roles
Where role_type_cd = 'BUDGET'
And enable_flag = 'Y'
And(  business_group_id = l_business_group_id
OR business_group_id IS NULL );

CURSOR csr_bg_id
IS
Select  business_group_id
From pqh_budget_pools
Where pool_id = p_transaction_id;

Cursor csr_seq_no (l_transaction_category_id IN number)  IS
Select max(substr(item_key,(length(l_transaction_category_id||'-'||p_transaction_id))+2,6) )
From wf_items
Where item_type='PQHGEN'
And item_key like l_transaction_category_id||'-'||p_transaction_id||'%';

l_proc                      varchar2(72) := g_package||'notify_bgt_manager_users';
l_role_id number(15);
l_role_name varchar2(30);
l_business_group_id number(15);
l_transaction_category_id number(15);
l_apply_error_mesg varchar2(4000);
l_apply_error_num number;
l_max_seq_no number(15);


Begin
hr_utility.set_location('Entering '||l_proc,10);
Open csr_bg_id;
Fetch csr_bg_id into l_business_group_id;
Close csr_bg_id;
hr_utility.set_location('Business Group id '||l_business_group_id||l_proc,12);
l_transaction_category_id := pqh_workflow.get_txn_cat
                              (p_short_name => 'PQH_BPR'
                              ,p_business_group_id => l_business_group_id);
hr_utility.set_location('transaction category id '||l_transaction_category_id||l_proc,15);

Open csr_bgt_manager_rls(l_business_group_id);
loop
  fetch csr_bgt_manager_rls into l_role_id,l_role_name;
  exit when csr_bgt_manager_rls%notfound;
  hr_utility.set_location('Transaction id   '||p_transaction_id||l_proc,20);
  hr_utility.set_location('Transaction name  '||p_transaction_name||l_proc,25);
  hr_utility.set_location('Role Id  '||l_role_id||l_proc,30);
  hr_utility.set_location('Role Name  '||l_role_name||l_proc,35);

  -- Get the maximun Sequence number
  Open csr_seq_no(l_transaction_category_id);
  Fetch csr_seq_no into l_max_seq_no;
  Close csr_seq_no;
  if l_max_seq_no is null then
     l_max_seq_no := 1;
  else
     l_max_seq_no := l_max_seq_no + 1;
  end if;
  hr_utility.set_location('Max Seq No   '||l_max_seq_no||l_proc,37);
   pqh_wf.process_user_action( P_TRANSACTION_CATEGORY_ID => l_transaction_category_id,
                               P_TRANSACTION_ID => p_transaction_id,
                               P_USER_ACTION_CD => 'PQH_BPR',
                               p_workflow_seq_no => l_max_seq_no,
                               P_FORWARDED_TO_ROLE_ID => l_role_id,
                               P_ROUTE_TO_USER  => 'PQH_ROLE:'||l_role_id,
                               P_TRANSACTION_NAME => p_transaction_name,
                               P_APPLY_ERROR_MESG => l_apply_error_mesg,
                               P_APPLY_ERROR_NUM  => l_apply_error_num);
  If (l_apply_error_num <> 0) then
      hr_utility.set_location('error encountered '||l_proc,40);
      fnd_message.set_name(8302,'PQH_BPR_PROCESS_LOG_ERROR');
      fnd_message.raise_error;
  End if;

End loop;
Close csr_bgt_manager_rls;
hr_utility.set_location('Leaving '||l_proc,50);

End notify_bgt_manager_users;

FUNCTION fyi_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'fyi_notification' ;
  l_folder_name     varchar2(2000);
  l_entity_type     varchar2(80);
  l_budget_unit     varchar2(80);
  l_approval_status  varchar2(100);
  cursor c0 is select  name,
                       hr_general.decode_lookup('PQH_BUDGET_ENTITY',ENTITY_TYPE),
                       hr_general.decode_shared_type(budget_unit_id),
                       hr_general.decode_lookup('PQH_REALLOC_TXN_STATUS',approval_status)
               from pqh_budget_pools
               where pool_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside fyi notification'||l_proc,10);
  open c0;
  fetch c0 into l_folder_name,l_entity_type, l_budget_unit, l_approval_status;
  close c0;
  hr_utility.set_location('Folder name, Approval Status fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_BPR_WF_FYI_NOTICE');
  hr_utility.set_message_token('FOLDER_NAME',l_folder_name);
  hr_utility.set_message_token('ENTITY_TYPE',l_entity_type);
  hr_utility.set_message_token('BUDGET_UNIT',l_budget_unit);
  hr_utility.set_message_token('APPROVAL_STATUS',l_approval_status);
  l_document := hr_utility.get_message;
  return l_document;
  exception
  when others then
     hr_utility.set_message(8302,'PQH_BPR_WF_FYI_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END fyi_notification;

PROCEDURE update_folder_approval_status (p_transaction_id in number, p_action_flag in varchar2)
IS
/* This procedure updates the folder approval status as 'P' (Pending)
   if the action flag is I (InBox) , F (Forward)
 */

Cursor csr_pool_dtls IS
Select *
From pqh_budget_pools
Where pool_id = p_transaction_id;

l_pool_rec  csr_pool_dtls%ROWTYPE;
l_proc   varchar2(72) := g_package||'update_folder_approval_status';
l_transaction_category_id number;

BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
--added by kgowripe
hr_multi_message.enable_message_list;
--end changes by kgowripe
   OPEN csr_pool_dtls;
   FETCH csr_pool_dtls INTO  l_pool_rec;
   CLOSE csr_pool_dtls;
   hr_utility.set_location('Txn Cat Id  '||l_transaction_category_id ,15);

   if ( l_pool_rec.approval_status = 'T' and (p_action_flag = 'I'  OR
                                              p_action_flag = 'F' ))
   then
         pqh_budget_pools_api.update_reallocation_folder(p_effective_date=> hr_general.effective_date
                                                 ,p_folder_id => p_transaction_id
                                                 ,p_object_version_number=>l_pool_rec.object_version_number
                                                 ,p_business_group_id => l_pool_rec.business_group_id
                                                 ,p_approval_status=> 'P'
                                                 ,p_wf_transaction_category_id => l_pool_rec.wf_transaction_category_id);
  end if;
Exception
--added by kgowripe
  when hr_multi_message.error_message_exist then
    Null;
End update_folder_approval_status;
PROCEDURE bgt_dummy_folder_delete(p_business_group_id IN number)
is

/*
This procedure deletes all folders whose approval_status is T (created)
i.e the folders which are created but not routed.
*/
Cursor csr_approval_status_T_folders IS
Select pool_id
From pqh_budget_pools
Where approval_status = 'T'
And business_group_id = p_business_group_id
AND creation_date < sysdate - 2;

l_folder_id pqh_budget_pools.pool_id%type;
l_proc    varchar2(72) := g_package ||'bgt_dummy_folder_delete';

BEGIN

hr_utility.set_location(' Entering:' || l_proc,10);
--added by kgowripe
hr_multi_message.enable_message_list;
--end changes by kgowripe
Open  csr_approval_status_T_folders;
loop
     hr_utility.set_location('Folder Id :' || l_folder_id ,20);
     fetch csr_approval_status_T_folders into l_folder_id;
     exit when csr_approval_status_T_folders%NOTFOUND;
     If l_folder_id is Not Null Then
        /* In the procedure pqh_budget_pools_swi.bgt_realloc_delete
           node_type T is marked as Transaction.
           So here passed TCF (Tempory Created Folder) as node type
           to distinguish with Transaction
         */
       BEGIN
         pqh_budget_pools_swi.bgt_realloc_delete(p_node_type => 'TCF'
                                            ,p_node_id   =>l_folder_id);
       EXCEPTION
         When Others Then
              Null;
       END;
     End If;
end loop;
close csr_approval_status_T_folders;
hr_utility.set_location(' Leaving:' || l_proc,30);
Exception
  When others Then
     Null;
END bgt_dummy_folder_delete;

PROCEDURE chk_bpr_route_catg_exist(p_business_group_id IN Number,
                                   p_status out nocopy varchar2) IS

 l_txn_catg_id Number;
 l_route_catg_id Number;
CURSOR csr_rout_catg(p_txn_catg_id IN Number) IS
   SELECT routing_category_id
   FROM   pqh_routing_categories
   WHERE  transaction_category_id = p_txn_catg_id;
BEGIN
  l_txn_catg_id := pqh_workflow.get_txn_cat('PQH_BPR',p_business_group_id);
  OPEN csr_rout_catg(l_txn_catg_id);
  FETCH csr_rout_catg INTO l_route_catg_id;
  IF csr_rout_catg%NOTFOUND THEN
    p_status := 'FALSE';
  ELSE
    p_status := 'TRUE';
  END IF;
  CLOSE csr_rout_catg;
END chk_bpr_route_catg_exist;

-- Added procedure by mvanakda
PROCEDURE bpr_process_user_action(
             	  p_transaction_id                IN  NUMBER
	         ,p_transaction_category_id       IN  NUMBER
	         ,p_route_to_user                 IN  VARCHAR2
	         ,p_routing_category_id           IN  NUMBER
	         ,p_pos_structure_version_id      IN  NUMBER
	         ,p_user_action_cd                IN  VARCHAR2
	         ,p_forwarded_to_user_id          IN  NUMBER
	         ,p_forwarded_to_role_id          IN  NUMBER
	         ,p_forwarded_to_position_id      IN  NUMBER
	         ,p_forwarded_to_assignment_id    IN  NUMBER
	         ,p_forwarded_to_member_id        IN  NUMBER
	         ,p_forwarded_by_user_id          IN  NUMBER
	         ,p_forwarded_by_role_id          IN  NUMBER
	         ,p_forwarded_by_position_id      IN  NUMBER
	         ,p_forwarded_by_assignment_id    IN  NUMBER
	         ,p_forwarded_by_member_id        IN  NUMBER
	         ,p_effective_date                IN  DATE
	         ,p_approval_cd                   IN  VARCHAR2
	         ,p_member_cd                     In  VARCHAR2
	         ,p_transaction_name              IN  VARCHAR2
	         ,p_apply_error_mesg              OUT NOCOPY VARCHAR2
       		 ,p_apply_error_num               OUT NOCOPY NUMBER
       		 ,p_warning_mesg                  OUT NOCOPY VARCHAR2
       		 ) IS
l_proc    varchar2(72) := g_package ||'bpr_process_user_action';
l_return   varchar2(30);

--Added cursor by krmahade
CURSOR csr_get_bdgt_start_dt IS
    select bgt.budget_start_date
    from   pqh_budgets bgt,
           pqh_budget_versions bvr,
           pqh_budget_pools fld
    where  fld.pool_id = p_transaction_id
    and    fld.budget_version_id = bvr.budget_version_id
    and    bvr.budget_id = bgt.budget_id;

    l_effective_date date;
--end krmahade
BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);

  --Added by krmahade
  OPEN csr_get_bdgt_start_dt;
  FETCH  csr_get_bdgt_start_dt into l_effective_date;
  CLOSE csr_get_bdgt_start_dt;

  --End krmahade

  g_warning := 'FALSE';

  -- Svorugan : for bug fix : 2864971
        if (p_user_action_cd = 'REJECT') then
         --
           l_return   :=  pqh_bdgt_realloc_utility.reject_transaction(p_transaction_id);
           --
           hr_utility.set_location(' Action Rejection Status :' || l_return,26);
         --
        end if;
  -- End Svorugan

  hr_utility.set_location(' before call warning :' || g_warning,15);

  pqh_wf.process_user_action(
              	 p_transaction_id                 =>  p_transaction_id
  	         ,p_transaction_category_id        =>  p_transaction_category_id
  	         ,p_route_to_user                  =>  p_route_to_user
  	         ,p_routing_category_id            =>  p_routing_category_id
  	         ,p_pos_structure_version_id       =>  p_pos_structure_version_id
  	         ,p_user_action_cd                 =>  p_user_action_cd
  	         ,p_forwarded_to_user_id           =>  p_forwarded_to_user_id
  	         ,p_forwarded_to_role_id           =>  p_forwarded_to_role_id
  	         ,p_forwarded_to_position_id       =>  p_forwarded_to_position_id
  	         ,p_forwarded_to_assignment_id     =>  p_forwarded_to_assignment_id
  	         ,p_forwarded_to_member_id         =>  p_forwarded_to_member_id
  	         ,p_forwarded_by_user_id           =>  p_forwarded_by_user_id
  	         ,p_forwarded_by_role_id           =>  p_forwarded_by_role_id
  	         ,p_forwarded_by_position_id       =>  p_forwarded_by_position_id
  	         ,p_forwarded_by_assignment_id     =>  p_forwarded_by_assignment_id
  	         ,p_forwarded_by_member_id         =>  p_forwarded_by_member_id
  	         ,p_effective_date                 =>  NVL(l_effective_date,p_effective_date)
  	         ,p_approval_cd                    =>  p_approval_cd
  	         ,p_member_cd                      =>  p_member_cd
  	         ,p_transaction_name               =>  p_transaction_name
  	         ,p_apply_error_mesg               =>  p_apply_error_mesg
                 ,p_apply_error_num           	   =>  p_apply_error_num
       		 );
  hr_utility.set_location(' after call warning :' || g_warning,25);
  p_warning_mesg := g_warning;
hr_utility.set_location(' leaving:' || l_proc,40);
END bpr_process_user_action;

-- ----------------------------------------------------------------------------
-- |----------------------< check_approver_skip >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_approver_skip(p_transaction_category_id IN NUMBER)
RETURN VARCHAR2
IS
l_status VARCHAR2(10) := 'Y';
BEGIN
SELECT prevent_approver_skip
into l_status
from pqh_transaction_categories
where transaction_category_id = p_transaction_category_id;
IF l_status is null OR l_status = 'N' THEN
RETURN 'N';
ELSE
RETURN 'Y';
END IF;
END CHECK_APPROVER_SKIP;


-- ----------------------------------------------------------------------------
-- |----------------------< valid_user_opening >-------------------------------|
-- | Wrapper on top of pqh_workflow.valid_user_openingto allow multi messaging |
-- ----------------------------------------------------------------------------
procedure valid_user_opening(p_business_group_id           in number    default null,
                             p_short_name                  in varchar2  ,
                             p_transaction_id              in number    default null,
                             p_routing_history_id          in number    default null,
                             p_wf_transaction_category_id     out nocopy number,
                             p_glb_transaction_category_id    out nocopy number,
                             p_role_id                        out nocopy number,
                             p_role_template_id               out nocopy number,
                             p_status_flag                    out nocopy varchar2) is
l_result varchar2(100);
BEGIN
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
     pqh_workflow.valid_user_opening(
                     p_business_group_id           => p_business_group_id,
                     p_short_name                  => p_short_name,
                     p_transaction_id              => p_transaction_id,
                     p_routing_history_id          => p_routing_history_id,
                     p_wf_transaction_category_id  => p_wf_transaction_category_id,
                     p_glb_transaction_category_id => p_glb_transaction_category_id,
                     p_role_id                     => p_role_id,
                     p_role_template_id            => p_role_template_id,
                     p_status_flag                 => p_status_flag );

       if (p_status_flag <> 0 and hr_multi_message.exception_add ) then
            hr_utility.raise_error;
       end if;

    -- Get the return status and disable multi-messaging
    l_result := hr_multi_message.get_return_status_disable;


exception
    when hr_multi_message.error_message_exist then
       l_result := hr_multi_message.get_return_status_disable;
    when others then
       raise;

END valid_user_opening;

-- ----------------------------------------------------------------------------
-- |------------------------< get_folder_unit >-------------------------------|
-- | Function to return Folder Unit Desciption for Bdgt_Unit_Id. Bug #3027076.|
-- ----------------------------------------------------------------------------
FUNCTION get_folder_unit (p_budget_unit_id IN NUMBER)
RETURN  VARCHAR2 IS
--Cursor to fetch Folder Unit Desc
  CURSOR csr_folder_unit_desc IS
  SELECT stt.shared_type_name
    FROM per_shared_types st, per_shared_types_tl stt
   WHERE st.lookup_type       = 'BUDGET_MEASUREMENT_TYPE'
     AND(st.business_group_id = HR_GENERAL.get_business_group_id OR
         st.business_group_id IS NULL)
     AND st.shared_type_id    = p_budget_unit_id
     AND stt.shared_type_id   = st.shared_type_id
     AND stt.language = USERENV('LANG');
--Local Variables
  l_folder_unit_desc VARCHAR2(80);
BEGIN
  l_folder_unit_desc := NULL;
  OPEN csr_folder_unit_desc;
  FETCH csr_folder_unit_desc INTO l_folder_unit_desc;
  CLOSE csr_folder_unit_desc;
  RETURN l_folder_unit_desc;
EXCEPTION
  WHEN OTHERS THEN
    l_folder_unit_desc := NULL;
    RETURN l_folder_unit_desc;
END get_folder_unit;

End pqh_bdgt_realloc_utility;

/
