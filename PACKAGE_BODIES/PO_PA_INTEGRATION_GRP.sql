--------------------------------------------------------
--  DDL for Package Body PO_PA_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PA_INTEGRATION_GRP" AS
/* $Header: POXGPAVB.pls 120.4 2008/05/16 13:52:16 cvardia ship $ */

G_PKG_NAME             CONSTANT VARCHAR2(30) := 'PO_PA_INTEGRATION_GRP';

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_temp_labor_po
--Pre-reqs:
--  none
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Validates the PO line/header and the project information
--  that is passed in . the following validattions are performed
--   - The project and task belong to a valid PO distribution
--   - The PO line/header is in a valid status
--   - The person id associated with the PO is valid
--   - The price type for the PO line is valid
--   - The PO line/header is in a proper OU
--  Returns the PO line price for the given price type and the header currency
--  information
--Parameters:
--IN:
--p_api_version
--  Initial API version : Expected value is 1.0
--p_project_id
--  Project id for which the validation needs to be done
--p_task_id
--  Task id for which the validation needs to be done
--p_po_line_id
--  Unique ID of the PO Line
--p_price_type
--  The price type
--p_po_number
--  The PO number - segment1
--p_org_id
--  Operating Unit
--p_person id
--  Person entering the time card
--p_effective_date
--  Person effective date
--IN OUT
--p_po_header_id
--  PO header id
--p_po_line_id
--  PO line id
--OUT:
--x_po_line_amt
--  Sum of the distribution amounts for the given project task
--x_po_rate
--  PO line price for a particular price time (line unit price multiplied
--  by the multiplier for the price type
--x_currency_code
--  PO header currency
--x_curr_rate_type
--  PO header rate type
--x_curr_rate_date
--  PO header rate date
--x_currency_rate
--  PO header currency rate
--x_ret_status
--  (a) FND_API.G_RET_STS_SUCCESS - 'S' if successful
--  (b) FND_API.G_RET_STS_ERROR - 'E' if known error occurs
--  (c) FND_API.G_RET_STS_UNEXP_ERROR - 'U' if unexpected error occurs
--x_message_code
--      The applicable error message code
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE validate_temp_labor_po(p_api_version    IN NUMBER,
                                 p_project_id     IN NUMBER,
                                 p_task_id        IN NUMBER,
                                 p_po_number      IN VARCHAR2,--bug 7003781
                                 p_po_line_num    IN NUMBER,
                                 p_price_type     IN VARCHAR2,
                                 p_org_id         IN NUMBER,
                                 p_person_id      IN NUMBER,
                                 p_po_header_id   IN OUT NOCOPY NUMBER,
                                 p_po_line_id     IN OUT NOCOPY NUMBER,
                                 x_po_line_amt    OUT NOCOPY NUMBER,
                                 x_po_rate        OUT NOCOPY NUMBER,
                                 x_currency_code  OUT NOCOPY VARCHAR2,
                                 x_curr_rate_type OUT NOCOPY VARCHAR2,
                                 x_curr_rate_date OUT NOCOPY DATE,
                                 x_currency_rate  OUT NOCOPY NUMBER,
                                 x_vendor_id      OUT NOCOPY NUMBER,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_message_code   OUT NOCOPY VARCHAR2,
                                 p_effective_date IN DATE
                                ) IS

l_api_name              CONSTANT VARCHAR2(30) := 'validate_temp_labor_po';
l_api_version           CONSTANT NUMBER := 1.0;

l_line_location_id      PO_LINE_LOCATIONS_ALL.line_location_id%TYPE;
l_distribution_id       PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE; --BUG#7046429
l_person_id             PER_ALL_PEOPLE_F.person_id%TYPE;
l_assignment_id         NUMBER;

l_status_rec            PO_STATUS_REC_TYPE;
l_rcv_close_prf         VARCHAR2(1);

BEGIN
    -- Initialise the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check for API version
    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) )
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_message_code := to_char(sqlcode);
        return;
    END IF;

    -- Return if any of the required information is not provided
    IF p_project_id is null OR
       p_task_id is null  OR
       p_price_type is null OR
       (p_po_number is null and p_po_header_id is null) OR
       (p_po_line_num is null and p_po_line_id is null) OR
       p_org_id is null
    THEN
       x_return_status :=  FND_API.G_RET_STS_ERROR;
       x_message_code := 'PO_SVC_INVALID_PARAMS';
       return;
    END IF;

    -- Derive the PO header and line id's if not provided
    IF p_po_header_id is null THEN

      Begin

       -- Sql What : Gets the po header id for a given po number and OU
       -- Sql Why :  To validate the PO number
       SELECT po_header_id
       INTO  p_po_header_id
       FROM po_headers_all
       WHERE segment1 = p_po_number
       AND  org_id = p_org_id;

      Exception
        when others then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_message_code := 'PO_SVC_INVALID_PO_NUM';
         return;
      End;

    END IF;

    IF p_po_line_id is null THEN

     Begin

       -- Sql What : Gets the po line id for a given po line number and OU
       -- Sql Why :  To validate the PO line number
       SELECT po_line_id
       INTO  p_po_line_id
       FROM po_lines_all
       WHERE line_num = p_po_line_num
       AND po_header_id = p_po_header_id
       AND  org_id = p_org_id;

     Exception
        when others then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_message_code := 'PO_SVC_INVALID_PO_LINE';
         return;
     End;

    END IF;

     -- Check if the line is a rate based line
     IF not (PO_SERVICES_PVT.is_rate_based_line (p_po_line_id)) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_message_code := 'PO_SVC_INVALID_PO_LINE';
        return;
     END IF;

    -- Derive the shipment if for status check. As we already checked for
    -- rate based line we know that there will be a single shipment

       Begin

        -- Sql What : Gets the po line location id for a given po line id
        -- Sql Why :  To check the shipment status
        SELECT line_location_id
        INTO l_line_location_id
        FROM po_line_locations_all
        WHERE po_line_id = p_po_line_id;

       Exception
          When others then
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
             x_message_code := to_char(sqlcode);
             return;
       End;

      PO_DOCUMENT_CHECKS_GRP.po_status_check(
          p_api_version => 1.0
       ,  p_header_id => po_tbl_number( p_po_header_id )
       ,  p_release_id => po_tbl_number(null)
       ,  p_document_type => po_tbl_varchar30( null )
       ,  p_document_subtype => po_tbl_varchar30( null )
       ,  p_document_num => po_tbl_varchar30( NULL )
       ,  p_vendor_order_num => po_tbl_varchar30( NULL )
       ,  p_line_id => po_tbl_number( p_po_line_id )
       ,  p_line_location_id => po_tbl_number( l_line_location_id )
       ,  p_distribution_id => po_tbl_number( null )
       ,  p_mode => 'G_GET_STATUS'
       ,  p_lock_flag => 'N'
       ,  x_po_status_rec => l_status_rec
       ,  x_return_status => x_return_status
       );

     l_rcv_close_prf := nvl(fnd_profile.value('RCV_CLOSED_PO_DEFAULT_OPTION'),'N');

      IF (l_status_rec.AUTHORIZATION_STATUS(1) <> 'APPROVED'  OR
          l_status_rec.CANCEL_FLAG(1) = 'Y' OR
          l_status_rec.CLOSED_CODE(1)  in ('CLOSED','FINALLY CLOSED') OR
          l_status_rec.APPROVAL_FLAG(1) <> 'Y' OR
          l_status_rec.HOLD_FLAG(1) = 'Y' OR
          l_status_rec.FROZEN_FLAG(1) = 'Y'  OR
          (l_status_rec.CLOSED_CODE(1) = 'CLOSED FOR RECEIVING' and
           l_rcv_close_prf = 'N') )
      THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_message_code := 'PO_SVC_INVALID_PO_STATUS';
         return;
      END IF;


     -- Check if a valid distribution exists for the given project and task
     Begin

       -- Sql What : Gets the number of distributions for the given project task
       -- Sql Why :  To check the project task validity
       -- BUG#7046429
         SELECT  min(po_distribution_id)
         INTO    l_distribution_id
	     FROM    po_distributions_all
	     WHERE   po_line_id = p_po_line_id
  	         AND project_id = p_project_id
                 AND task_id    = p_task_id;

	   -- BUG#7046429
	   -- Get the first distribution from Purchase order which has a Dummy Project Associated.
	   -- This is used in the case when user select a Project on the Timecard which doesn't
           -- matches with the projects in Purchase Order which was selected on  Time card.

           IF l_distribution_id IS NULL THEN
              SELECT  MIN(psp.po_distribution_id)
              INTO    l_distribution_id
	              FROM    PO_SP_VAL_V psp
	              WHERE   psp.po_line_id           = p_po_line_id
		          AND psp.project_id           IS NOT NULL
	                  AND psp.task_id              IS NOT NULL
	                  AND psp.VALIDATE_PROJECT_FLAG = 'Y';
           END IF;

     if l_distribution_id IS NULL then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_message_code := 'PO_SVC_INVALID_PROJECT_TASK';
         return;
     end if;

     Exception
        when others then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_message_code := 'PO_SVC_INVALID_PROJECT_TASK';
         return;
     End;


     -- check if the price type is valid . skip the standard and fixed price types
     IF  p_price_type not in ('FIXED PRICE','STANDARD') AND
         not PO_PRICE_DIFFERENTIALS_PVT.is_price_type_enabled(p_price_type => p_price_type,
                                                             p_entity_type => 'PO LINE',
                                                             p_entity_id => p_po_line_id)
     THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_message_code := 'PO_SVC_INVALID_PRICE_TYPE';
        return;
     END IF;

     -- Validate with the person on the PO line if person id is passed in
     -- BUG#7046429
     -- If Association can also be in the New Table po_cwk_association.
     -- Which is verified by is_PO_active function.
     IF p_person_id is not null THEN
       HR_PO_INFO.get_person_for_po_line (p_po_line_id     => p_po_line_id,
                                          p_effective_date => p_effective_date,
                                          p_person_id      => l_person_id,
                                          p_assignment_id  => l_assignment_id
                                          );

	IF (   (l_person_id is null OR p_person_id <> l_person_id)AND
	   NOT (PO_PA_INTEGRATION_GRP.is_PO_active(p_person_id, p_effective_date,p_po_header_id,p_po_line_id)) )
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_message_code := 'PO_SVC_INVALID_PERSON';
          return;
       END IF;
     END IF;

     -- If we have come this far that means all validations passed and
     -- we now get the information from the PO to pass back to PA

     -- Get the line rate/currency info
        get_line_rate_info(   p_api_version    => 1.0,
                              p_price_type     => p_price_type,
                              p_po_line_id     => p_po_line_id,
                              p_project_id     => p_project_id,
                              p_task_id        => p_task_id,
                              x_po_rate        => x_po_rate,
                              x_currency_code  => x_currency_code,
                              x_curr_rate_type => x_curr_rate_type ,
                              x_curr_rate_date => x_curr_rate_date,
                              x_currency_rate  => x_currency_rate,
                              x_vendor_id      => x_vendor_id,
                              x_return_status  => x_return_status,
                              x_message_code   => x_message_code
                          );

     -- Get the total distribution amount for given project task

        Begin

           -- Sql What : Gets the total distribution amt for the given project task
           -- Sql Why :  For projects to calculate the cost for the project
           -- BUG#7046429
	   -- Get the Project/Task from the distribution which is relevant.
	   -- This Change is made because the Project selected by User on the Timecard might
	   -- match with the projects in Purchase Order and might doesn't matches.

           SELECT  sum(nvl(pod1.amount_ordered,0) - nvl(pod1.amount_cancelled,0))
           INTO    x_po_line_amt
           FROM    po_distributions_all pod1,
	           po_distributions_all pod2
           WHERE   pod1.po_line_id = pod2.po_line_id
                AND pod1.project_id = pod2.project_id
                AND pod1.task_id    = pod2.task_id
                AND pod2.po_distribution_id = l_distribution_id;

       Exception
          When others then
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
             x_message_code := to_char(sqlcode);
             return;
       End;


EXCEPTION
When Others then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_message_code := to_char(sqlcode);
END;

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_rate_based_line
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if a po line is rate based line
--Parameters:
--IN:
--p_po_line_id
--  Unique ID of the PO Line
--p_po_distribution_id
--  PO distribution id
--Returns:
--  TRUE if the PO line/distribution  is an rate based line. FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------

FUNCTION is_rate_based_line (p_po_line_id         IN NUMBER,
                             p_po_distribution_id IN NUMBER)
RETURN BOOLEAN IS

l_po_line_id  PO_LINES_ALL.po_line_id%TYPE;

BEGIN

     IF p_po_line_id is null and p_po_distribution_id is null THEN
       RETURN FALSE;
     END IF;

     IF p_po_line_id is null THEN

      Begin

        -- Sql What : Gets the line id for the given distribution
        -- Sql Why :  To check the line type
        SELECT po_line_id
        INTO  l_po_line_id
        FROM  po_distributions_all
        WHERE po_distribution_id = p_po_distribution_id;
      Exception
        When others then
        RETURN FALSE;
      End;

     ELSE

       l_po_line_id := p_po_line_id;

     END IF;

     -- Check if the line is a rate based line
     IF  (PO_SERVICES_PVT.is_rate_based_line (l_po_line_id)) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;

EXCEPTION
When Others then
    RETURN FALSE;
END;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_rate_info
--Pre-reqs:
--  none
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- Returns the PO line price for the given price type and the header currency
-- information
--Parameters:
--IN:
--p_api_version
--  Initial API version : Expected value is 1.0
--p_po_line_id
--  Unique ID of the PO Line
--p_price_type
--  The price type
--OUT:
--x_po_rate
--  PO line price for a particular price time (line unit price multiplied
--  by the multiplier for the price type
--x_currency_code
--  PO header currency
--x_curr_rate_type
--  PO header rate type
--x_curr_rate_date
--  PO header rate date
--x_currency_rate
--  PO header currency rate
--x_ret_status
--  (a) FND_API.G_RET_STS_SUCCESS - 'S' if successful
--  (b) FND_API.G_RET_STS_ERROR - 'E' if known error occurs
--  (c) FND_API.G_RET_STS_UNEXP_ERROR - 'U' if unexpected error occurs
--x_message_code
--      The applicable error message code  - none in this case
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_line_rate_info (p_api_version    IN NUMBER,
                              p_price_type     IN VARCHAR2,
                              p_po_line_id     IN NUMBER,
                              p_project_id     IN NUMBER,
                              p_task_id        IN NUMBER,
                              x_po_rate        OUT NOCOPY NUMBER,
                              x_currency_code  OUT NOCOPY VARCHAR2,
                              x_curr_rate_type OUT NOCOPY VARCHAR2,
                              x_curr_rate_date OUT NOCOPY DATE,
                              x_currency_rate  OUT NOCOPY NUMBER,
                              x_vendor_id      OUT NOCOPY NUMBER,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_message_code   OUT NOCOPY VARCHAR2
                             ) IS

l_api_name              CONSTANT VARCHAR2(30) := 'get_line_rate_info';
l_api_version           CONSTANT NUMBER := 1.0;

l_po_header_id          PO_HEADERS_ALL.po_header_id%TYPE;
l_price                 NUMBER := null;
l_distribution_id       PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE;
l_rate                  PO_DISTRIBUTIONS_ALL.rate%TYPE;
l_rate_date             PO_DISTRIBUTIONS_ALL.rate_date%TYPE;
l_base_currency_code    GL_SETS_OF_BOOKS.currency_code%TYPE;

BEGIN
    -- Initialise the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check for API version
    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) )
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_message_code := to_char(sqlcode);
    END IF;

    -- Get the price for the price type and line price
    PO_PRICE_DIFFERENTIALS_PVT.get_price_for_price_type(p_entity_id   =>  p_po_line_id,
                                                        p_entity_type =>  'PO LINE',
                                                        p_price_type  =>  p_price_type,
                                                        x_price       =>  l_price);

    x_po_rate := l_price;

    -- get the functional currency
    l_base_currency_code := PO_CORE_S2.get_base_currency;

    -- Get the PO header id to derive the currency info
    Begin

      -- Sql What : Gets the header id and the vendor id from the header
      --            for the given line
      -- Sql Why :  To get the currency info
      SELECT poh.po_header_id,
             poh.vendor_id
      INTO   l_po_header_id,
             x_vendor_id
      FROM   po_lines_all pol,
             po_headers_all poh
      WHERE  pol.po_header_id = poh.po_header_id
      AND    pol.po_line_id = p_po_line_id;

    Exception
      When others then
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_message_code := to_char(sqlcode);
       return;
    End;

    -- Get the currency Info from the PO
    PO_CORE_S2.get_po_currency_info(p_po_header_id  => l_po_header_id,
                                x_currency_code => x_currency_code,
                                x_curr_rate_type => x_curr_rate_type,
                                x_curr_rate_date => x_curr_rate_date,
                                x_currency_rate => x_currency_rate);

    -- If the PO currency is different from the functional currency
    -- get the rate and rate date from the distribution if available
    IF x_currency_code <> l_base_currency_code THEN

     -- Get the minimam distribution id for the given project and task
     Begin
           -- Sql What : Gets the minimam distribution id for the give project/task
           -- Sql Why :  To get the currency info
           SELECT  min(po_distribution_id)
           INTO    l_distribution_id
           FROM    po_distributions_all
           WHERE   po_line_id = p_po_line_id
           AND     project_id = p_project_id
           AND     task_id    = p_task_id;

	   -- BUG#6972530
	   -- Get the first distribution from Purchase order which has a Dummp Project Associated.
	   -- This is used in the case when user select a Project on the Timecard which doesn't
           -- matches with the projects in Purchase Order which was selected on  Time card.

           IF l_distribution_id IS NULL THEN
              SELECT  MIN(psp.po_distribution_id)
              INTO    l_distribution_id
              FROM    PO_SP_VAL_V psp
              WHERE   psp.po_line_id           = p_po_line_id
                  AND psp.project_id           IS NOT NULL
                  AND psp.task_id              IS NOT NULL
                  AND psp.VALIDATE_PROJECT_FLAG = 'Y';
           END IF;

     Exception
          When others then
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
             x_message_code := to_char(sqlcode);
             return;
     End;

     -- Get the rate and rate date from the distribution and return them
     -- if they are not null
     Begin
           -- Sql What : Gets the rate info for the min distribution
           -- Sql Why :  To get the rate info
           SELECT  rate_date,
                   rate
           INTO    l_rate_date,
                   l_rate
           FROM    po_distributions_all
           WHERE   po_distribution_id = l_distribution_id;

     Exception
          When others then
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
             x_message_code := to_char(sqlcode);
             return;
     End;

     if l_rate_date is not null then
         x_curr_rate_date := l_rate_date;
     end if;

     if l_rate is not null then
         x_currency_rate := l_rate;
     end if;

   END IF;  -- end if functional currency and base currency not equal


EXCEPTION
When Others then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_message_code := to_char(sqlcode);
END;

FUNCTION is_PO_active
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_po_header_id         IN         NUMBER
    ,p_po_line_id           IN         NUMBER)
  RETURN BOOLEAN IS

  l_api_name           CONSTANT VARCHAR2(30) := 'is_PO_active';
  l_log_head           CONSTANT VARCHAR2(100) := G_PKG_NAME || l_api_name;
  l_api_version        CONSTANT NUMBER := 1.0;
  l_progress           VARCHAR2(3) := '000';
  X_flag               VARCHAR2(1):='N';
  l_effective_date DATE;

BEGIN

    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Start');
    l_progress:=010;

    --BUG#7046429  p_effective data can be passed as NULL.
    l_effective_date := nvl(p_effective_date,TRUNC(sysdate));

    IF p_person_id IS NOT NULL AND l_effective_date IS NOT NULL
    AND p_po_header_id IS NOT NULL AND p_po_line_id IS NOT NULL
    THEN

      BEGIN
         select 'Y'
         INTO X_flag
         from dual
         where exists(
              SELECT po_header_id,po_line_id
              FROM  po_sp_val_v
              where person_id = p_person_id
              AND fnd_date.canonical_to_date(fnd_date.date_to_canonical(l_effective_date)) >=
                               fnd_date.canonical_to_date(fnd_date.date_to_canonical(pol_start_date))
              AND fnd_date.canonical_to_date(fnd_date.date_to_canonical(l_effective_date)) <=
                               fnd_date.canonical_to_date(fnd_date.date_to_canonical(pol_expiration_date))
              AND fnd_date.canonical_to_date(fnd_date.date_to_canonical(l_effective_date)) >=
                               fnd_date.canonical_to_date(fnd_date.date_to_canonical(assignmt_effective_start_date))
              AND fnd_date.canonical_to_date(fnd_date.date_to_canonical(l_effective_date)) <=
                               fnd_date.canonical_to_date(fnd_date.date_to_canonical(assignmt_effective_end_date))
              AND po_header_id = p_po_header_id
              AND po_line_id = p_po_line_id
              );


      EXCEPTION
         when OTHERS THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'No data found');
            RETURN FALSE;
      END;
    END IF;
          l_progress:=020;
      IF X_flag='Y' THEN
             PO_DEBUG.debug_stmt(l_log_head,l_progress,'Record found');
             RETURN TRUE;
      ELSE
             PO_DEBUG.debug_stmt(l_log_head,l_progress,'No data found');
             RETURN FALSE;
      END IF;
END is_PO_active;


END PO_PA_INTEGRATION_GRP;

/
