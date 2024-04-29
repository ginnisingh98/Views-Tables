--------------------------------------------------------
--  DDL for Package Body RCV_DISTRIBUTIONS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_DISTRIBUTIONS_S" AS
/* $Header: RCVTXDIB.pls 120.5.12010000.3 2010/10/14 19:10:22 vthevark ship $*/




/*===========================================================================

  PROCEDURE NAME: get_distributions_info

===========================================================================*/

PROCEDURE get_distributions_info
   (X_line_location_id      IN          NUMBER,
    X_shipment_line_id      IN          NUMBER,
    X_item_id         IN          NUMBER,
    X_num_of_distributions     IN OUT NOCOPY      NUMBER,
    X_po_distributions_id   OUT NOCOPY         NUMBER,
    X_destination_type_code    IN OUT NOCOPY      VARCHAR2,
    X_destination_type_dsp     OUT NOCOPY         VARCHAR2,
    X_deliver_to_location_id   IN OUT NOCOPY      NUMBER,
    X_deliver_to_location   OUT NOCOPY         VARCHAR2,
    X_deliver_to_person_id  IN OUT NOCOPY      NUMBER,
    X_deliver_to_person     OUT NOCOPY         VARCHAR2,
    X_deliver_to_sub     IN OUT NOCOPY      VARCHAR2,
    X_deliver_to_locator_id    OUT NOCOPY         NUMBER,
    X_deliver_to_locator    OUT NOCOPY         VARCHAR2,
    X_wip_entity_id              IN OUT NOCOPY      NUMBER,
    X_wip_repetitive_schedule_id IN OUT NOCOPY      NUMBER,
    X_wip_line_id                IN OUT NOCOPY      NUMBER,
    X_wip_operation_seq_num      IN OUT NOCOPY      NUMBER,
    X_wip_resource_seq_num       IN OUT NOCOPY      NUMBER,
    X_bom_resource_id            IN OUT NOCOPY      NUMBER,
    X_to_organization_id         IN OUT NOCOPY      NUMBER,
    X_job                        IN OUT NOCOPY      VARCHAR2,
    X_line_num                   IN OUT NOCOPY      VARCHAR2,
    X_sequence                   IN OUT NOCOPY      NUMBER,
    X_department                 IN OUT NOCOPY      VARCHAR2,
    X_rate                       IN OUT NOCOPY      NUMBER,
    X_rate_date                  IN OUT NOCOPY      DATE,
-- <RCV ENH FPI START>
    x_kanban_card_number         OUT NOCOPY  VARCHAR2,
    x_project_number             OUT NOCOPY  VARCHAR2,
    x_task_number                OUT NOCOPY  VARCHAR2,
    x_charge_account             OUT NOCOPY  VARCHAR2
-- <RCV ENH FPI END>
   ) IS

X_progress VARCHAR2(3) := NULL;

X_valid_ship_to_location     BOOLEAN;
X_valid_deliver_to_location  BOOLEAN;
X_valid_deliver_to_person    BOOLEAN;
X_valid_subinventory         BOOLEAN;

-- <RCV ENH FPI START>
l_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_code_combination_id PO_DISTRIBUTIONS.code_combination_id%TYPE;
-- <RCV ENH FPI END>

/* Bug 3816908 : Variable added */
l_lookup_type           po_lookup_codes.lookup_type%TYPE;

x_project_id   PO_DISTRIBUTIONS.project_id%type; -- bug 3867151
x_task_id      PO_DISTRIBUTIONS.task_id%type;    -- bug 3867151

l_asn_line_flag rcv_shipment_lines.asn_line_flag%TYPE ; -- bug 9732431
l_po_distribution_id po_distributions_all.po_distribution_id%TYPE; --bug 9732431

BEGIN

   X_progress := '010';

   /*    Get the number of distributions so as to know whether to return
      one or to just show multiple as the return value
   */
   SELECT  count(po_distribution_id)
   INTO    X_num_of_distributions
   FROM    po_distributions
   WHERE   line_location_id = X_line_location_id;

  /* Bug 9732431 when asn receipt on multiple distribion,
    each asn create one shipment line,
    we should not regard the ASN shipment line as multiple lines.
  */

   IF X_num_of_distributions >1 AND X_SHIPMENT_LINE_ID IS NOT NULL  THEN
     SELECT Nvl(asn_line_flag,'N'),
            po_distribution_id
     INTO  l_asn_line_flag,
           l_po_distribution_id
     FROM rcv_shipment_lines
     WHERE shipment_line_id = X_SHIPMENT_LINE_ID ;

     IF l_asn_line_flag = 'Y' THEN
       IF  X_po_distributions_id IS NULL THEN
            X_po_distributions_id := l_po_distribution_id;
       END IF;

       IF X_po_distributions_id IS NOT NULL  THEN
          X_num_of_distributions :=1 ;
       END IF;
     END IF;
   END IF ;

   /*End Bug 9732431 */

   /*    If there are no distributions for this line_location_id then you
   must have passed a bad value.  We should raise an error for this
   */
   IF X_num_of_distributions = 0 THEN

      X_progress := '011';

      po_message_s.sql_error ('get_distribution_info', X_progress, SQLCODE);
      RAISE NO_DATA_FOUND;

   /* If there is one distribution then go ahead and fetch the destination
   from the po_distributions table
   */
   ELSIF X_num_of_distributions = 1 THEN

      X_progress := '020';

      /* Bug# 1808822 - HR_LOCATIONS view is non-mergable so it is replaced by
         hr_locations_all_tl and the condition hl.language(+) = USERENV('LANG')
         is added. Since only location_code is selected, there is no need of
         joining with the tables hr_locations_all and hz_locations. */

      SELECT  pod.po_distribution_id,
              pod.destination_type_code,
              pod.deliver_to_location_id,
              hl.location_code,
              pod.deliver_to_person_id,
              pod.destination_subinventory,
              pod.wip_entity_id,
              pod.WIP_REPETITIVE_SCHEDULE_ID,
              pod.WIP_LINE_ID,
              pod.WIP_OPERATION_SEQ_NUM,
              pod.WIP_RESOURCE_SEQ_NUM,
              pod.BOM_RESOURCE_ID,
              pod.destination_organization_id,
              round(pod.rate,28),
              pod.rate_date,
              mkc.kanban_card_number,  -- <RCV ENH FPI>
              pod.project_id,          -- bug 3867151
              pod.task_id,             -- bug 3867151
              pod.code_combination_id  -- <RCV ENH FPI>
      INTO    X_po_distributions_id,
         X_destination_type_code,
              X_deliver_to_location_id,
              X_deliver_to_location,
              X_deliver_to_person_id,
              X_deliver_to_sub,
              X_wip_entity_id,
              X_wip_repetitive_schedule_id,
              X_wip_line_id,
              X_wip_operation_seq_num,
              X_wip_resource_seq_num,
              X_bom_resource_id,
              X_to_organization_id,
              X_rate,
              X_rate_date,
              x_kanban_card_number,   -- <RCV ENH FPI>
              x_project_id,       -- <RCV ENH FPI>Bug 4684017 The variable should be x_project_id and not x_project_number
              x_task_id,          -- <RCV ENH FPI>Bug 4684017 The variable should be x_project_id and not x_project_number
              l_code_combination_id   -- <RCV ENH FPI>
      FROM    po_distributions pod,
              hr_locations_all_tl hl,
              mtl_kanban_cards mkc    -- <RCV ENH FPI>
      WHERE   pod.line_location_id = X_line_location_id
      AND     pod.po_distribution_id = Nvl(X_PO_DISTRIBUTIONS_ID,pod.po_distribution_id)    -- bug 9732431
      AND     hl.location_id(+) = pod.deliver_to_location_id
      AND     hl.language(+) = USERENV('LANG')
      AND     pod.kanban_card_id = mkc.kanban_card_id (+);   -- <RCV ENH FPI>


      /* Bug 3867151 START
         Due to performance problems because of outer joins on project_id and
         task_id related conditions in the above sql, writing a separate select
         to retrieve the project and task numbers. This sql will be executed
         only when project/task references are there in the PO distribution.
      */

      x_progress  := 21;

      IF (x_project_id IS NOT NULL) THEN
         BEGIN
	 /*Bugfix5217513 SQLID:17869796 Rewritten queries
            SELECT ppa.project_number,
                   pte.task_number
            INTO   x_project_number,
                   x_task_number
            FROM   pjm_projects_all_v ppa,
                   pa_tasks_expend_v pte
            WHERE  ppa.project_id = x_project_id
            AND    pte.task_id = x_task_id
            AND    ppa.project_id = pte.project_id;*/

       /* Bug 5290928: Added condition task_id not null.
                       If the organization is only project controlled,
                       task is not mandatory. */
            IF x_task_id IS NOT NULL THEN
                select P.SEGMENT1 PROJECT_NUMBER ,
                       T.TASK_NUMBER
                  into x_project_number,
                       x_task_number
                  from PA_PROJECTS_ALL p,
                       PA_TASKS T
                 where P.PROJECT_ID = T.PROJECT_ID
                   and p.project_id = x_project_id
                   and T.task_id = x_task_id;
            ELSE
                select SEGMENT1 PROJECT_NUMBER
                  into x_project_number
                  from PA_PROJECTS_ALL
                 where project_id = x_project_id;
            END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                 select PROJECT_NUMBER
                   into x_project_number
                   from PJM_SEIBAN_NUMBERS
                  where project_id = x_project_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     x_project_number  := NULL;
                     x_task_number     := NULL;
              END;
         END;
      ELSE
         x_project_number  := NULL;
         x_task_number     := NULL;
      END IF;

      /* Bug 3867151 END */

      X_deliver_to_person :=
    po_inq_sv.get_person_name(X_deliver_to_person_id);

-- <RCV ENH FPI START>
      x_progress := '025';

      x_charge_account :=
          PO_COMPARE_REVISIONS.get_charge_account(l_code_combination_id);
-- <RCV ENH FPI END>

      /*
      ** Make sure this information is still valid
      */
      rcv_transactions_sv.val_destination_info (
         X_to_organization_id,
         X_item_id,
         NULL,
         X_deliver_to_location_id,
         X_deliver_to_person_id,
         X_deliver_to_sub,
         X_valid_ship_to_location,
         X_valid_deliver_to_location,
         X_valid_deliver_to_person,
         X_valid_subinventory);

      IF (NOT X_valid_deliver_to_location) THEN

         X_deliver_to_location_id := NULL;
         X_deliver_to_location := NULL;

      END IF;

      IF (NOT X_valid_deliver_to_person) THEN

         X_deliver_to_person_id := NULL;
         X_deliver_to_person := NULL;

      END IF;

      IF (NOT X_valid_subinventory) THEN

         X_deliver_to_sub := NULL;

      END IF;

      /*
      ** Check to see if you have a wip entity id.  If you do then do get the
      ** wip info for that distribution
      */
      IF (x_wip_entity_id > 0) THEN

         rcv_transactions_sv.get_wip_info
           (X_wip_entity_id,
            X_wip_repetitive_schedule_id,
            X_wip_line_id,
            X_wip_operation_seq_num,
            X_wip_resource_seq_num,
            X_to_organization_id,
            X_job,
            X_line_num,
            X_sequence,
            X_department);

      END IF;

   /* If there is more than one distribution for a given line then
   just return the status that there are multiple distributions
   */
   ELSE

-- <RCV ENH FPI START>
     x_progress := '028';

     RCV_DISTRIBUTIONS_S.get_misc_distr_info (
       x_return_status => l_status,
       p_line_location_id => x_line_location_id,
       p_po_distribution_id => NULL,
       x_kanban_card_number => x_kanban_card_number,
       x_project_number => x_project_number,
       x_task_number => x_task_number,
       x_charge_account => x_charge_account,
       x_deliver_to_person => x_deliver_to_person,
       x_job => x_job,
       x_outside_line_num => x_line_num,
       x_sequence => x_sequence,
       x_department => x_department,
       x_dest_subinv => x_deliver_to_sub,
       x_rate => x_rate,
       x_rate_date => x_rate_date);

     IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
-- <RCV ENH FPI END>

      X_destination_type_code := 'MULTIPLE';

   END IF;

   /* If you have at least one distribution then go get the display
      value for that destination type from the lookups table
   */
   IF X_num_of_distributions > 0 THEN

      X_progress := '030';
      /* Bug 3816908: Replaced hardcoded literals for lookup_type with
       *              bind variables.
       */

      l_lookup_type := 'RCV DESTINATION TYPE';

      SELECT  displayed_field
      INTO    X_destination_type_dsp
      FROM    po_lookup_codes
      WHERE   lookup_type = l_lookup_type
      AND     lookup_code = X_destination_type_code;

   END IF;


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error ('get_distribution_info', X_progress, SQLCODE);
      RAISE;

END get_distributions_info;

/*===========================================================================

  PROCEDURE NAME: test_rcv_distributions_s

===========================================================================*/

PROCEDURE test_rcv_distributions_s
   (X_line_location_id     IN NUMBER,
    X_shipment_line_id     IN NUMBER,
    X_item_id                   IN NUMBER    ) IS

X_num_of_distributions     NUMBER;
X_po_distributions_id         NUMBER;
X_destination_type_code       VARCHAR2(30);
X_destination_type_dsp        VARCHAR2(80);
X_deliver_to_location_id   NUMBER;

/** PO UTF8 Column Expansion Project 9/23/2002 tpoon **/
/** Changed X_deliver_to_location to use %TYPE **/
-- X_deliver_to_location         VARCHAR2(30);
X_deliver_to_location         hr_locations_all.location_code%TYPE;

X_deliver_to_person_id        NUMBER;
X_deliver_to_person        VARCHAR2(30);
X_deliver_to_sub        VARCHAR2(30);
X_deliver_to_locator_id       NUMBER;
X_deliver_to_locator    VARCHAR2(30);
X_wip_entity_id                 NUMBER;
X_wip_repetitive_schedule_id    NUMBER;
X_wip_line_id                   NUMBER;
X_wip_operation_seq_num         NUMBER;
X_wip_resource_seq_num          NUMBER;
X_bom_resource_id               NUMBER;
X_to_organization_id            NUMBER;
X_job                           VARCHAR2(240);
X_line_num                      VARCHAR2(10);
X_sequence                      NUMBER;
X_department                    VARCHAR2(10);
X_rate                          NUMBER;
X_rate_date                     DATE;

BEGIN

   /* Test the get_distributions_info procedure */

-- <RCV ENH FPI START>
-- Remove the get_distributions_info call because this procedure is not
-- used anywhere, and the package will not compile if we do not remove
-- the call.

     NULL;
--   RCV_DISTRIBUTIONS_S.get_distributions_info
--      (X_line_location_id, X_shipment_line_id, X_item_id,
--       X_num_of_distributions,
--       X_po_distributions_id, X_destination_type_code, X_destination_type_dsp,
--       X_deliver_to_location_id, X_deliver_to_location,
--       X_deliver_to_person_id, X_deliver_to_person, X_deliver_to_sub,
--       X_deliver_to_locator_id, X_deliver_to_locator,X_wip_entity_id,
--       X_wip_repetitive_schedule_id,X_wip_line_id,X_wip_operation_seq_num ,
--       X_wip_resource_seq_num , X_bom_resource_id ,
--       X_to_organization_id  ,  X_job ,  X_line_num  , X_sequence ,
--       X_department, X_rate, X_rate_date
--  );

-- <RCV ENH FPI END>

   /* Print the results of the test */
   /*dbms_output.put_line('Line Location Id:       ' ||
      to_char(X_line_location_id));
   dbms_output.put_line('Shipment Id:            ' ||
      to_char(X_shipment_line_id));
   dbms_output.put_line('Num of Dist:            ' ||
      to_char(X_num_of_distributions));
   dbms_output.put_line('Dist ID:            ' ||
      to_char(X_po_distributions_id));
   dbms_output.put_line('Dest Type Code:         ' ||
      X_destination_type_code);
   dbms_output.put_line('Dest Type Dsp:          ' ||
      X_destination_type_dsp);
   dbms_output.put_line('Deliver To Location Id: ' ||
      to_char(X_deliver_to_location_id));
   dbms_output.put_line('Deliver To Loc:         ' ||
      X_deliver_to_location);
   dbms_output.put_line('Deliver To Person Id:   ' ||
      to_char(X_deliver_to_person_id));
   dbms_output.put_line('Deliver To Person:      ' ||
      X_deliver_to_person);
   dbms_output.put_line('Deliver To Sub:         ' ||
      X_deliver_to_sub);
   dbms_output.put_line('Deliver To Locator Id:  ' ||
      to_char(X_deliver_to_locator_id));
   dbms_output.put_line('Deliver To Locator:     ' ||
      X_deliver_to_locator);
   dbms_output.put_line('X_wip_entity_id: ' ||
      to_char(X_wip_entity_id));
   dbms_output.put_line('X_wip_repetitive_schedule_id: ' ||
      to_char(X_wip_repetitive_schedule_id));
   dbms_output.put_line('X_wip_line_id: ' ||
      to_char(X_wip_line_id));
   dbms_output.put_line('X_wip_operation_seq_num: ' ||
      to_char(X_wip_operation_seq_num));
   dbms_output.put_line('X_wip_resource_seq_num: ' ||
      to_char(X_wip_resource_seq_num));
   dbms_output.put_line('X_bom_resource_id: ' ||
      to_char(X_bom_resource_id));
   dbms_output.put_line('X_to_organization_id: ' ||
      to_char(X_to_organization_id));
   dbms_output.put_line('X_job: ' ||
      X_job);
   dbms_output.put_line('X_line_num: ' ||
      X_line_num);
   dbms_output.put_line('X_sequence: ' ||
      to_char(X_sequence));
   dbms_output.put_line('X_department: ' ||
      X_department);
   dbms_output.put_line('X_rate: ' || to_char(x_rate));
   dbms_output.put_line('X_rate_date: ' || to_char(x_rate_date,'dd-mon-yyyy'));
 */
END test_rcv_distributions_s;


-- <RCV ENH FPI START>

/**
* Public Procedure: get_misc_distr_info
* Requires: p_line_location_id and p_po_distribution_id should be valid
*           values in PO_LINE_LOCATIONS and PO_DISTRIBUTIONS
* Modifies: None
* Effects:  if p_line_location_id is given and po_distribution_id is NULL,
*           then it returns distribution information (kanban_card_number,
*           project_number, etc.) If there is only 1 distribution. If there
*           are multiple distributions, return 'Multiple' if not all
*           distributions have null value. If
*           po_distribution_id is given, then return distribution information
*           based on that distribution id.
* Returns:
* x_return_status:
*   FND_API.G_RET_STS_SUCCESS if no error occurs
*   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs (e.g.,
*     line_location_id does not exist in PO_LINE_LOCATIONS)
* x_kanban_card_number:
*   Kanban Card Number. NULL if distribution does not contain kanban card info
* x_project_number:
*   Project Number. NULL if distribution does not contain project info.
* x_task_number:
*   Task Number.  NULL if distribution does not contain task info.
* x_charge_account:
*   Concatenated Charge Account Segments.
* x_deliver_to_person:
*   Requestor. NULL if distribution does not contain requestor info.
* x_job
*   Job/Schedule. Null if distribution does not contain such info.
* x_outside_line_num
*   Outside Processing related Display Info
* x_sequence
*   Outside Processing related Display Info
* x_department
*   Outside Processing related Display Info
* x_rate
*   Currency rate
* x_rate_date
*   Currency rate date
*/

PROCEDURE get_misc_distr_info
(x_return_status         OUT NOCOPY VARCHAR2,
 p_line_location_id      IN NUMBER,
 p_po_distribution_id    IN NUMBER,
 x_kanban_card_number    OUT NOCOPY VARCHAR2,
 x_project_number        OUT NOCOPY VARCHAR2,
 x_task_number           OUT NOCOPY VARCHAR2,
 x_charge_account        OUT NOCOPY VARCHAR2,
 x_deliver_to_person     OUT NOCOPY VARCHAR2,
 x_job                   OUT NOCOPY VARCHAR2,
 x_outside_line_num      OUT NOCOPY VARCHAR2,
 x_sequence              OUT NOCOPY NUMBER,
 x_department            OUT NOCOPY VARCHAR2,
 x_dest_subinv           OUT NOCOPY VARCHAR2,
 x_rate                  OUT NOCOPY NUMBER,
 x_rate_date             OUT NOCOPY DATE) IS

  l_api_name CONSTANT VARCHAR2(50) := 'get_misc_distr_info';

  l_num_distributions NUMBER;
  l_num_projs NUMBER;
  l_num_tasks NUMBER;
  l_num_kanban_cards NUMBER;
  l_num_charge_accts NUMBER;
  l_num_requestors NUMBER;
  l_num_jobs NUMBER;
  l_num_rates NUMBER;
  l_num_rate_dates NUMBER;
  l_num_dest_subinv NUMBER;

  --Bugfix5217513: Introduced Variables.
  l_project_id NUMBER;
  l_task_id NUMBER;

  l_wip_entity_id PO_DISTRIBUTIONS.wip_entity_id%TYPE;
  l_wip_rep_schedule_id PO_DISTRIBUTIONS.wip_repetitive_schedule_id%TYPE;
  l_wip_line_id PO_DISTRIBUTIONS.wip_line_id%TYPE;
  l_wip_operation_seq_num PO_DISTRIBUTIONS.wip_operation_seq_num%TYPE;
  l_wip_resource_seq_num PO_DISTRIBUTIONS.wip_resource_seq_num%TYPE;
  l_to_organization_id PO_DISTRIBUTIONS.destination_organization_id%TYPE;

  l_multi_distr VARCHAR2(1) := FND_API.G_FALSE;
  l_multiple_msg VARCHAR2(2000);

  l_progress VARCHAR2(3);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_progress := '000';

  IF (p_line_location_id IS NULL) THEN
    RETURN;
  END IF;

  IF (p_po_distribution_id IS NULL) THEN
    SELECT COUNT(po_distribution_id),
           COUNT(kanban_card_id),
           COUNT(project_id),
           COUNT(task_id),
           COUNT(code_combination_id),
           COUNT(deliver_to_person_id),
           COUNT(wip_entity_id),
           COUNT(rate),
           COUNT(rate_date),
           COUNT(destination_subinventory)
    INTO   l_num_distributions,
           l_num_kanban_cards,
           l_num_projs,
           l_num_tasks,
           l_num_charge_accts,
           l_num_requestors,
           l_num_jobs,
           l_num_rates,
           l_num_rate_dates,
           l_num_dest_subinv
    FROM   po_distributions
    WHERE  line_location_id = p_line_location_id;

    IF (l_num_distributions > 1) THEN

      l_progress := '010';

      l_multi_distr := FND_API.G_TRUE;

      FND_MESSAGE.set_name('PO', 'PO_MULTI_DEST_INFO');
      l_multiple_msg := FND_MESSAGE.get;

      IF (l_num_projs > 0) THEN
        x_project_number := l_multiple_msg;
      END IF;

      IF (l_num_tasks > 0) THEN
        x_task_number := l_multiple_msg;
      END IF;

      IF (l_num_kanban_cards > 0) THEN
        x_kanban_card_number := l_multiple_msg;
      END IF;

      IF (l_num_charge_accts > 0) THEN
        x_charge_account := l_multiple_msg;
      END IF;

      IF (l_num_requestors > 0) THEN
        x_deliver_to_person := l_multiple_msg;
      END IF;

      IF (l_num_jobs > 0) THEN
        x_job := l_multiple_msg;
      END IF;

      IF (l_num_dest_subinv > 0) THEN
        x_dest_subinv := l_multiple_msg;
      END IF;
    END IF;
  END IF;

  IF (l_multi_distr = FND_API.G_FALSE) THEN

    l_progress := '020';

--SQL What: Retreive Distribution Information by distribution_id
--SQL       or line_location_id having only 1 distribution
--SQL Why: These are the return values of this procedure
--SQL Join: POD and PPA: project_id
--SQL       POD and PTE: task_id
--SQL       POD and MKC: kanban_card_id
--Bugfix5217513 SQLID: 17869745
    SELECT MKC.kanban_card_number,
           --PPA.project_number,
           --PTE.task_number,
	   POD.project_id,
	   POD.task_id,
           PO_COMPARE_REVISIONS.get_charge_account(POD.code_combination_id),
           PO_INQ_SV.get_person_name(POD.deliver_to_person_id),
           POD.destination_subinventory,
           POD.wip_entity_id,
           POD.wip_repetitive_schedule_id,
           POD.wip_line_id,
           POD.wip_operation_seq_num,
           POD.wip_resource_seq_num,
           POD.destination_organization_id,
           ROUND(POD.rate, 28),
           POD.rate_date
    INTO   x_kanban_card_number,
           --x_project_number,
           --x_task_number,
	   l_project_id,
	   l_task_id,
           x_charge_account,
           x_deliver_to_person,
           x_dest_subinv,
           l_wip_entity_id,
           l_wip_rep_schedule_id,
           l_wip_line_id,
           l_wip_operation_seq_num,
           l_wip_resource_seq_num,
           l_to_organization_id,
           x_rate,
           x_rate_date
    FROM   po_distributions_all POD, --Bug 10177530
           --pjm_projects_all_v PPA,
           --pa_tasks_expend_v PTE,
           mtl_kanban_cards MKC
    WHERE  POD.po_distribution_id = NVL(p_po_distribution_id,
                                        POD.po_distribution_id)
    AND    POD.line_location_id = p_line_location_id
    --AND    POD.project_id = PPA.project_id (+)
    --AND    POD.task_id = PTE.task_id (+)
    AND    POD.kanban_card_id = MKC.kanban_card_id (+);

    IF l_project_id IS NOT NULL THEN
         BEGIN
    /* Bug 5290928: Added condition task_id not null.*/
            IF l_task_id IS NOT NULL THEN
                select P.SEGMENT1 PROJECT_NUMBER ,
                       T.TASK_NUMBER
                  into x_project_number,
                       x_task_number
                  from PA_PROJECTS_ALL p,
                       PA_TASKS T
                 where P.PROJECT_ID = T.PROJECT_ID
                   and p.project_id = l_project_id
                   and T.task_id = l_task_id;
            ELSE
                select SEGMENT1 PROJECT_NUMBER
                  into x_project_number
                  from PA_PROJECTS_ALL
                 where project_id = l_project_id;
            END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  select PROJECT_NUMBER
                    into x_project_number
                    from PJM_SEIBAN_NUMBERS
                   where project_id = l_project_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     x_project_number  := NULL;
                     x_task_number     := NULL;
               END;
         END;
      ELSE
         x_project_number  := NULL;
         x_task_number     := NULL;
      END IF;

    /*
     ** Check to see if you have a wip entity id.  If you do then do get the
     ** wip info for that distribution
     */
    IF (l_wip_entity_id > 0) THEN
      l_progress := '030';
      rcv_transactions_sv.get_wip_info
           (l_wip_entity_id,
            l_wip_rep_schedule_id,
            l_wip_line_id,
            l_wip_operation_seq_num,
            l_wip_resource_seq_num,
            l_to_organization_id,
            X_job,
            X_outside_line_num,
            X_sequence,
            X_department);
    END IF;

    l_progress := '040';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    PO_MESSAGE_S.sql_error (l_api_name, l_progress, SQLCODE);
END get_misc_distr_info;


/**
* Public Procedure: get_misc_req_distr_info
* Requires: p_requisition_line_id and p_req_distribution_id should be valid
*           values in PO_REQUISITION_LINES and PO_REQ_DISTRIBUTIONS
* Modifies: None
* Effects:  get kanban card information from req line, project, task and
*           charge account information from req distribution
* Returns:
* x_return_status:
*   FND_API.G_RET_STS_SUCCESS if no error occurs
*   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs (e.g.,
*     line_location_id does not exist in PO_LINE_LOCATIONS)
* x_kanban_card_number:
*   Kanban Card Number. NULL if distribution does not contain kanban card info
* x_project_number:
*   Project Number. NULL if distribution does not contain project info.
* x_task_number:
*   Task Number.  NULL if distribution does not contain task info.
* x_charge_account:
*   Concatenated Charge Account Segments.
* x_deliver_to_person:
*   Requestor
* x_dest_subinv:
*   Subinventory defined in Requisition
*/

PROCEDURE get_misc_req_distr_info
(x_return_status         OUT NOCOPY VARCHAR2,
 p_requisition_line_id   IN NUMBER,
 p_req_distribution_id   IN NUMBER,
 x_kanban_card_number    OUT NOCOPY VARCHAR2,
 x_project_number        OUT NOCOPY VARCHAR2,
 x_task_number           OUT NOCOPY VARCHAR2,
 x_charge_account        OUT NOCOPY VARCHAR2,
 x_deliver_to_person     OUT NOCOPY VARCHAR2,
 x_dest_subinv           OUT NOCOPY VARCHAR2) IS

  l_api_name CONSTANT VARCHAR2(50) := 'get_misc_req_distr_info';
  l_progress VARCHAR2(3) := '000';
  x_project_id  PO_REQ_DISTRIBUTIONS.project_id%type; -- bug 3867151
  x_task_id     PO_REQ_DISTRIBUTIONS.task_id%type;    -- bug 3867151
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_requisition_line_id IS NOT NULL) THEN
    l_progress := '010';

--SQL What: Retreive information from requisition line and distribution. If no
--SQL       distribution id then use req_line_id only because there is
--SQL       always one and only one distribution per req line for
--SQL       an internal req.
--SQL Why:  Return values of this procedure
--SQL Join: PRL and PRD: requisition_line_id
--SQL       PRL and MKC: kanban_card_id
--SQL       PRD and PPA: project_id
--SQL       PRD and PTE: task_id

    SELECT MKC.kanban_card_number,
           PO_INQ_SV.get_person_name(PRL.to_person_id),
           PRL.destination_subinventory,
           PRD.project_id,      -- bug 3867151
           PRD.task_id,         -- bug 3867151
           PO_COMPARE_REVISIONS.get_charge_account(PRD.code_combination_id)
    INTO   x_kanban_card_number,
           x_deliver_to_person,
           x_dest_subinv,
           x_project_id,        -- bug 3867151
           x_task_id,           -- bug 3867151
           x_charge_account
    FROM   po_requisition_lines PRL,
           po_req_distributions PRD,
           mtl_kanban_cards MKC
    WHERE  PRL.requisition_line_id = p_requisition_line_id
    AND    PRL.requisition_line_id = PRD.requisition_line_id
    AND    PRD.distribution_id = NVL(p_req_distribution_id,PRD.distribution_id)
    AND    PRL.kanban_card_id = MKC.kanban_card_id (+);
  END IF;

  l_progress := '020';

   /* Bug 3867151 START
      Due to performance problems because of outer joins on project_id and
      task_id related conditions in the above sql, writing a separate select
      to retrieve the project and task numbers. This sql will be executed
      only when project/task references are there in the PO distribution.
   */
   IF (x_project_id IS NOT NULL) THEN
      BEGIN
        /*Bugfix 5217513: SQLID 17869671 Rewritten queries.
         SELECT ppa.project_number,
                pte.task_number
         INTO   x_project_number,
                x_task_number
         FROM   pjm_projects_all_v ppa,
                pa_tasks_expend_v pte
         WHERE  ppa.project_id = x_project_id
         AND    pte.task_id = x_task_id
         AND    ppa.project_id = pte.project_id;*/

       /* Bug 5290928: Added condition task_id not null.*/
            IF x_task_id IS NOT NULL THEN
                select P.SEGMENT1 PROJECT_NUMBER ,
                       T.TASK_NUMBER
                  into x_project_number,
                       x_task_number
                  from PA_PROJECTS_ALL p,
                       PA_TASKS T
                 where P.PROJECT_ID = T.PROJECT_ID
                   and p.project_id = x_project_id
                   and T.task_id = x_task_id;
            ELSE
                select SEGMENT1 PROJECT_NUMBER
                  into x_project_number
                  from PA_PROJECTS_ALL
                 where project_id = x_project_id;
            END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               select PROJECT_NUMBER
                 into x_project_number
                 from PJM_SEIBAN_NUMBERS
                where project_id = x_project_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_project_number  := NULL;
                  x_task_number     := NULL;
            END;
      END;
   ELSE
      x_project_number  := NULL;
      x_task_number     := NULL;
   END IF;
   /* Bug 3867151 END */

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    PO_MESSAGE_S.sql_error (l_api_name, l_progress, SQLCODE);
END get_misc_req_distr_info;

-- <RCV ENH FPI END>

END RCV_DISTRIBUTIONS_S;

/
