--------------------------------------------------------
--  DDL for Package Body PQH_PSP_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PSP_INTEGRATION" AS
/* $Header: pqhpspkg.pkb 115.4 2003/09/24 23:35:50 kgowripe noship $ */
--
-----------------------------------------------------------------------------
-- |                     Private Global Definitions
-----------------------------------------------------------------------------
--
g_asg_bgt_tab               t_assignment_budget_tab;
g_encumbered_entity_tab  t_enc_entity_tab;
g_package                   varchar2(25) := 'pqh_psp_integration';
--

-----------------------------------------------------------------------------
-- Private procedure to get Encumbered/Liquidated Assignments and Periods
-----------------------------------------------------------------------------
/*
LD call returns a Pl/Sql record with Assignment, Element,Period and Amount
details for Encumbered/Liquidated Assignments.
But we are interested only in Assignment and Period details and we dont want
Element Details.
This procedure finds Assignment and Min/Max Encumbered Periods irrespective
of Elements Involved.
*/

Procedure get_distinct_assignments
(
  p_assg_ele_tab IN  psp_pqh_integration.assignment_enc_ld_col
)  IS
--
Cursor csr_period_date(p_time_period_id  in  number) is
 Select start_date,end_date
   From per_time_periods
   Where time_period_id = p_time_period_id;

--------Local Variables-----------------------------------------------

i              NUMBER :=1;
l_start_date   DATE;
l_end_date     DATE;
l_start_period NUMBER;
l_end_period   NUMBER;
l_proc         VARCHAR2(72) := g_package||'get_distinct_assignments';


Begin
--
hr_utility.set_location('Entering: '||l_proc, 5);
--
g_asg_bgt_tab(1).assignment_id    :=p_assg_ele_tab.r_assignment_id(1);
l_start_period                    :=p_assg_ele_tab.r_begin_time_period_id(1);
l_end_period                      := p_assg_ele_tab.r_end_time_period_id(1);
--
Open csr_period_date(l_start_period);
Fetch csr_period_date into l_start_date, l_end_date;
Close csr_period_date;
g_asg_bgt_tab(1).start_period  :=l_start_date;
--
Open csr_period_date(l_end_period);
Fetch csr_period_date into l_start_date, l_end_date;
Close csr_period_date;
g_asg_bgt_tab(1).end_period    :=l_end_date;
--
For cnt in 2..p_assg_ele_tab.r_assignment_id.COUNT
 LOOP
 --
 IF(g_asg_bgt_tab(i).assignment_id = p_assg_ele_tab.r_assignment_id(cnt))

  THEN
  --
  IF (l_start_period  <> p_assg_ele_tab.r_begin_time_period_id(cnt) Or
      l_end_period    <> p_assg_ele_tab.r_end_time_period_id(cnt))
  THEN
  Open csr_period_date(p_assg_ele_tab.r_begin_time_period_id(cnt));
  Fetch csr_period_date into l_start_date, l_end_date;
  Close csr_period_date;
  IF ( l_start_date < g_asg_bgt_tab(i).start_period)
  THEN
  l_start_period :=p_assg_ele_tab.r_begin_time_period_id(cnt);
  g_asg_bgt_tab(i).start_period  :=l_start_date;
  END IF;
  Open csr_period_date(p_assg_ele_tab.r_end_time_period_id(cnt));
  Fetch csr_period_date into l_start_date, l_end_date;
  Close csr_period_date;
  IF ( l_end_date  > g_asg_bgt_tab(i).end_period)
    THEN
    l_end_period :=p_assg_ele_tab.r_end_time_period_id(cnt);
    g_asg_bgt_tab(i).end_period  :=l_end_date;
  END IF;
  END IF;
  --
  Else
   --
   i :=i+1;
   g_asg_bgt_tab(i).assignment_id    :=p_assg_ele_tab.r_assignment_id(cnt);
   l_start_period :=p_assg_ele_tab.r_begin_time_period_id(cnt);
   l_end_period := p_assg_ele_tab.r_end_time_period_id(cnt);
   Open csr_period_date(l_start_period);
   Fetch csr_period_date into l_start_date, l_end_date;
   Close csr_period_date;
   g_asg_bgt_tab(i).start_period  :=l_start_date;
   Open csr_period_date(l_end_period);
   Fetch csr_period_date into l_start_date, l_end_date;
   Close csr_period_date;
   g_asg_bgt_tab(i).end_period    :=l_end_date;
   --
  END IF;

 --
 END LOOP;
hr_utility.set_location('Leaving:'||l_proc, 1000);
--
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END;

-----------------------------------------------------------------------------
-- Private procedure to get Entities attached to Enc/Liquidated Assignment
-----------------------------------------------------------------------------
/*
Given a set of Assignments and Encumbered Period this procedure will find
all Entites attatched to those Assignments in that period.
Eg:
---LD Encumbrance Details---                ----Assignment Details-----------------
Assignment  Start Period  End Period        Assignment Start Date  End date    Position
A1          01-jan-2000   30-Jun-2000       A1         01-jan-2000 15-jan-2000 P1
                                            A1         15-jan-2000 31-mar-2000 P2
                                            A1         01-apr-2000 30-jun-2000 P3
For this assignment we will pick positions P1,P2,P3.

Note that Positions may repeate. But when fnding Budget Versions we will take
care that Budget Version in not repeated even though position is repeated.
*/
Procedure get_asg_entities IS
--
Cursor csr_asg_entities(p_assignment_id NUMBER,p_start_date DATE, p_end_date DATE) IS
Select position_id ,organization_id,
       grade_id,job_id,
       effective_start_date,effective_end_date
 From per_all_assignments_f
 Where assignment_id=p_assignment_id And
       position_id is not null And
       effective_start_date >= p_start_date And
       effective_end_date   <= p_end_date;

i NUMBER :=0;
l_proc           VARCHAR2(72) := g_package||'get_asg_entities';
--
Begin
--
hr_utility.set_location('Entering: '||l_proc, 5);
For cnt in 1..g_asg_bgt_tab.COUNT
 LOOP
 --
 FOR C1 in csr_asg_entities(g_asg_bgt_tab(cnt).assignment_id,
                            g_asg_bgt_tab(cnt).start_period,
                            g_asg_bgt_tab(cnt).end_period)
 LOOP
 --
 i :=i+1;
 g_encumbered_entity_tab(i).position_id     :=C1.position_id;
 g_encumbered_entity_tab(i).organization_id :=C1.organization_id;
 g_encumbered_entity_tab(i).grade_id        :=C1.grade_id;
 g_encumbered_entity_tab(i).job_id          :=C1.job_id;
 g_encumbered_entity_tab(i).start_period    :=C1.effective_start_date;
 g_encumbered_entity_tab(i).end_period      :=C1.effective_end_date;
 --
 END LOOP;
 --
 END LOOP;
 hr_utility.set_location('Leaving:'||l_proc, 1000);
--
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END;

-----------------------------------------------------------------------------
-- Private procedure to get Budget Versions from Assignment Positions
-----------------------------------------------------------------------------
/*
Given a set of Positions this procedure will find Budget Versions coresponding
to those Positions.
However Budget Version will be considered only if
1.Budget is marked for Transfer to GMS
2.Corresponding Budget detail is already posted to Target system
3.Budget Version is  already posted to Target system

Also care is taken that Budget version is not repeated even though 2 different
positions may belong to same budget version.
*/
Procedure get_budget_versions
(
 l_versions_tab  OUT NOCOPY PSP_PQH_INTEGRATION.t_num_15_type
) IS
--
-----------------------Cursors----------------------------------------------------
Cursor csr_position_budget(p_position_id NUMBER,
                           p_start_date date,
                           p_end_date date) IS
Select bdt.budget_detail_id ,bdt.budget_version_id
From   pqh_budget_details  bdt,
       pqh_budget_versions bvr,
       pqh_budgets         bgt
Where
     bdt.position_id=p_position_id And
     bdt.gl_status='POST' And
     bvr.budget_version_id=bdt.budget_version_id And
     bvr.gl_status='POST' And
     bgt.budget_id=bvr.budget_id And
     bgt.TRANSFER_TO_GRANTS_FLAG='Y' And
     bgt.budgeted_entity_cd='POSITION'AND
     ( (bgt.budget_start_date>=p_start_date and bgt.budget_start_date < p_end_date) Or
       (bgt.budget_end_date > P_start_date and bgt.budget_end_date   <=p_end_date )Or
       (p_start_date >=bgt.budget_end_date and p_start_date < bgt.budget_end_date )
     );


Cursor csr_org_budget(p_organization_id NUMBER,
                           p_start_date date,
                           p_end_date date) IS
Select bdt.budget_detail_id ,bdt.budget_version_id
From   pqh_budget_details  bdt,
       pqh_budget_versions bvr,
       pqh_budgets         bgt
Where
     bdt.organization_id=p_organization_id And
     bdt.gl_status='POST' And
     bvr.budget_version_id=bdt.budget_version_id And
     bvr.gl_status='POST' And
     bgt.budget_id=bvr.budget_id And
     bgt.TRANSFER_TO_GRANTS_FLAG='Y' And
     bgt.budgeted_entity_cd='ORGANIZATION'AND
     ( (bgt.budget_start_date>=p_start_date and bgt.budget_start_date < p_end_date) Or
       (bgt.budget_end_date > P_start_date and bgt.budget_end_date   <=p_end_date )Or
       (p_start_date >=bgt.budget_end_date and p_start_date < bgt.budget_end_date )
     );



Cursor csr_grade_budget(p_grade_id NUMBER,
                           p_start_date date,
                           p_end_date date) IS
Select bdt.budget_detail_id ,bdt.budget_version_id
From   pqh_budget_details  bdt,
       pqh_budget_versions bvr,
       pqh_budgets         bgt
Where
     bdt.grade_id=p_grade_id And
     bdt.gl_status='POST' And
     bvr.budget_version_id=bdt.budget_version_id And
     bvr.gl_status='POST' And
     bgt.budget_id=bvr.budget_id And
     bgt.TRANSFER_TO_GRANTS_FLAG='Y' And
     bgt.budgeted_entity_cd='GRADE'AND
     ( (bgt.budget_start_date>=p_start_date and bgt.budget_start_date < p_end_date) Or
       (bgt.budget_end_date > P_start_date and bgt.budget_end_date   <=p_end_date )Or
       (p_start_date >=bgt.budget_end_date and p_start_date < bgt.budget_end_date )
     );


Cursor csr_job_budget(p_job_id NUMBER,
                           p_start_date date,
                           p_end_date date) IS
Select bdt.budget_detail_id ,bdt.budget_version_id
From   pqh_budget_details  bdt,
       pqh_budget_versions bvr,
       pqh_budgets         bgt
Where
     bdt.job_id=p_job_id And
     bdt.gl_status='POST' And
     bvr.budget_version_id=bdt.budget_version_id And
     bvr.gl_status='POST' And
     bgt.budget_id=bvr.budget_id And
     bgt.TRANSFER_TO_GRANTS_FLAG='Y' And
     bgt.budgeted_entity_cd='JOB'AND
     ( (bgt.budget_start_date>=p_start_date and bgt.budget_start_date < p_end_date) Or
       (bgt.budget_end_date > P_start_date and bgt.budget_end_date   <=p_end_date )Or
       (p_start_date >=bgt.budget_end_date and p_start_date < bgt.budget_end_date )
     );

----------------------------Local Variables-----------------------------------------

i                NUMBER :=0;
version_repeated BOOLEAN;
l_proc           VARCHAR2(72) := g_package||'get_budget_versions';


Begin
--
hr_utility.set_location('Entering: '||l_proc, 5);
--
-- For each Encumbered Entity
--
For cnt in 1..g_encumbered_entity_tab.COUNT
 LOOP
 --
 -- If Assignment has a Position attached
 --
 IF g_encumbered_entity_tab(cnt).position_id is NOT NULL
 THEN
  FOR C1 in csr_position_budget(g_encumbered_entity_tab(cnt).position_id,
                                g_encumbered_entity_tab(cnt).start_period,
                                g_encumbered_entity_tab(cnt).end_period)
  LOOP
  --
   version_repeated :=false;
   For inx in 1..l_versions_tab.COUNT
   LOOP
   --
    IF (C1.budget_version_id = l_versions_tab(inx))
    THEN
     version_repeated :=true;
     EXIT;
    END IF;
   --
   END LOOP;
   IF ( not version_repeated )
   THEN
    i :=i+1;
    l_versions_tab(i) :=C1.budget_version_id;
    Update pqh_budget_details
      SET commitment_gl_status='ENC',gl_status='ENC'
    Where budget_detail_id = C1.budget_detail_id;
   END IF;
  --
  END LOOP;
 END IF;
 --
 --If Assignment has Organization attached
 --
  IF g_encumbered_entity_tab(cnt).organization_id is NOT NULL
  THEN
   FOR C1 in csr_org_budget(g_encumbered_entity_tab(cnt).organization_id,
                            g_encumbered_entity_tab(cnt).start_period,
                            g_encumbered_entity_tab(cnt).end_period)
   LOOP
   --
    version_repeated :=false;
    For inx in 1..l_versions_tab.COUNT
    LOOP
    --
     IF (C1.budget_version_id = l_versions_tab(inx))
     THEN
      version_repeated :=true;
      EXIT;
     END IF;
    --
    END LOOP;
    IF ( not version_repeated )
    THEN
     i :=i+1;
     l_versions_tab(i) :=C1.budget_version_id;
     Update pqh_budget_details
       SET commitment_gl_status='ENC',gl_status='ENC'
     Where budget_detail_id = C1.budget_detail_id;
    END IF;
   --
   END LOOP;
  END IF;
 --
 --If Assignment has Grade attached
 --
   IF g_encumbered_entity_tab(cnt).grade_id is NOT NULL
   THEN
    FOR C1 in csr_grade_budget(g_encumbered_entity_tab(cnt).grade_id,
                               g_encumbered_entity_tab(cnt).start_period,
                               g_encumbered_entity_tab(cnt).end_period)
    LOOP
    --
     version_repeated :=false;
     For inx in 1..l_versions_tab.COUNT
     LOOP
     --
      IF (C1.budget_version_id = l_versions_tab(inx))
      THEN
       version_repeated :=true;
       EXIT;
      END IF;
     --
     END LOOP;
     IF ( not version_repeated )
     THEN
      i :=i+1;
      l_versions_tab(i) :=C1.budget_version_id;
      Update pqh_budget_details
       SET commitment_gl_status='ENC',gl_status='ENC'
      Where budget_detail_id = C1.budget_detail_id;
     END IF;
     --
    END LOOP;
   END IF;
 --
 --If Assignment has Job attached
 --
   IF g_encumbered_entity_tab(cnt).job_id is NOT NULL
   THEN
    FOR C1 in csr_job_budget(g_encumbered_entity_tab(cnt).job_id,
                             g_encumbered_entity_tab(cnt).start_period,
                             g_encumbered_entity_tab(cnt).end_period)
    LOOP
    --
     version_repeated :=false;
     For inx in 1..l_versions_tab.COUNT
     LOOP
     --
      IF (C1.budget_version_id = l_versions_tab(inx))
      THEN
       version_repeated :=true;
       EXIT;
      END IF;
     --
     END LOOP;
     IF ( not version_repeated )
     THEN
      i :=i+1;
      l_versions_tab(i) :=C1.budget_version_id;
      Update pqh_budget_details
        SET commitment_gl_status='ENC',gl_status='ENC'
      Where budget_detail_id = C1.budget_detail_id;
     END IF;
    --
    END LOOP;
   END IF;
  --
 END LOOP;
hr_utility.set_location('Leaving:'||l_proc, 1000);
--
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END;

-----------------------------------------------------------------------------
-- Main procedure called by LD Encumbrane and Summarize/Liquidation process
-----------------------------------------------------------------------------
/*
This procedure is called by LD whenever assignments are encumbered or lquidated.
This procedure picks up all assignments encumbered by LD and identifies Budget
Version involved based on Assignment positions.
For each such budget version we will call
Budget Transfer process
Commitment Calculation process
Commitment Transfer Process
in that order.
These individual processes will take care of relieving PQH commitments.
*/

PROCEDURE  relieve_budget_commitments( p_calling_process IN  VARCHAR2,
                                       p_return_status   OUT NOCOPY VARCHAR2) IS
--
l_assignment_enc_ld_table      psp_pqh_integration.assignment_enc_ld_col;
l_distinct_assignment_table    t_assignment_budget_tab;
l_encumbered_positions_table   PSP_PQH_INTEGRATION.t_num_15_type;
l_budget_versions_table        PSP_PQH_INTEGRATION.t_num_15_type;
l_psp_encumbered               BOOLEAN;
l_return_status                varchar2(2);
l_proc                         varchar2(72) := g_package||'relieve_budget_commitments';
l_err                          varchar2(100);
l_ret                          varchar2(100);
l_budget_version               number(15);
--
BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);
 PSP_PQH_INTEGRATION.GET_ENCUMBRANCE_DETAILS(
     P_CALLING_PROCESS          =>p_calling_process,
     P_ASSIGNMENT_ENC_LD_TABLE  =>l_assignment_enc_ld_table,
     P_PSP_ENCUMBERED           =>l_psp_encumbered,
     P_RETURN_STATUS            =>l_return_status);

 IF( l_return_status <> FND_API.G_RET_STS_SUCCESS)
 THEN
 --
 p_return_status:=FND_API.G_RET_STS_ERROR;
 RETURN;
 --
--added for fixing bug#3153433
-- check whether the assignments are encumbered or not and proceed.
 ELSIF NOT (l_psp_encumbered) THEN

 p_return_status:=FND_API.G_RET_STS_SUCCESS;
 RETURN;
--end changes for bug#3153433
 END IF;

 --Get Assignmetns and Period os Encumbrance
 get_distinct_assignments(l_assignment_enc_ld_table);

 -- Get Postions attached to Encumbered/Liquidated assignmnts
 get_asg_entities;

 --Get Budget Versions of Assignment Positions
 get_budget_versions(l_budget_versions_table);

 --For each Budget Version call Budget Xfer, Commitment Calculation and Commiment Xfer
 For cnt in 1..l_budget_versions_table.COUNT
  LOOP
  --
  l_budget_version :=l_budget_versions_table(cnt);
  pqh_commitment_pkg.calculate_commitment(
                                          errbuf               =>l_err,
                                          retcode              => l_ret,
                                          p_budgeted_entity_cd  =>'POSITION',
                                          p_budget_version_id  =>l_budget_version
                                          );
 pqh_gl_posting.post_budget(
                            p_budget_version_id=>l_budget_version,
                            p_status            =>l_ret
                           );

 pqh_commitment_posting.post_budget_commitment(
                                               errbuf=>l_err,
                                               retcode => l_ret,
                                               p_effective_date =>sysdate,
                                               p_budget_version_id=>l_budget_version
                                              );
  --
 END LOOP;

 p_return_status:=FND_API.G_RET_STS_SUCCESS;
 hr_utility.set_location('Leaving:'||l_proc, 1000);
 EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK ;
      p_return_status:=FND_API.G_RET_STS_ERROR;
      hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
      hr_utility.set_message_token('ROUTINE', l_proc);
      hr_utility.set_message_token('REASON', SQLERRM);
      hr_utility.raise_error;
 END relieve_budget_commitments;
 --
 --
END PQH_PSP_INTEGRATION;

/
