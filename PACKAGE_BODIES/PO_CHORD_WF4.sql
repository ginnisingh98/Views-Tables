--------------------------------------------------------
--  DDL for Package Body PO_CHORD_WF4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHORD_WF4" AS
/* $Header: POXWCO4B.pls 120.2 2006/03/08 16:34:56 dreddy noship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

PROCEDURE chord_dist(itemtype IN VARCHAR2,
		      itemkey  IN VARCHAR2,
		      actid    IN NUMBER,
		      funcmode IN VARCHAR2,
		      result   OUT NOCOPY VARCHAR2)
IS
	x_dist_control		t_dist_control_type;
	x_dist_parameters	t_dist_parameters_type;
BEGIN

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: chord_dist ***' );
	END IF;

	IF funcmode <> 'RUN' THEN
		result := 'COMPLETE';
		return;
	END IF;

	get_wf_dist_parameters(itemtype, itemkey, x_dist_parameters);

	check_dist_change(itemtype, itemkey, x_dist_parameters, x_dist_control);

	set_wf_dist_control(itemtype, itemkey, x_dist_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: chord_dist ***' );
	END IF;

	result := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
	return;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf4.chord_dist', 'others');
  RAISE;

END;

PROCEDURE check_dist_change(
		itemtype IN VARCHAR2,
		itemkey  IN VARCHAR2,
		x_dist_parameters IN t_dist_parameters_type,
		x_dist_control IN OUT NOCOPY t_dist_control_type)
IS
  x_po_header_id			NUMBER:=NULL;
  x_po_release_id			NUMBER:=NULL;
  e_invalid_setup			EXCEPTION;
  l_currency_code   VARCHAR2(15);
  l_min_acct_unit   VARCHAR2(15);
  l_precision       VARCHAR2(15);
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: check_dist_change ***' );
	END IF;

	x_dist_control.distribution_num  	:= 'N';
	x_dist_control.deliver_to_person_id  	:= 'N';
	x_dist_control.rate 			:= 'N';
	x_dist_control.rate_date 	   	:= 'N';
	x_dist_control.gl_encumbered_date  	:= 'N';
	x_dist_control.code_combination_id 	:= 'N';
	x_dist_control.destination_subinventory	:= 'N';
	x_dist_control.quantity_ordered_change	:=0;
	x_dist_control.rate_change		:=0;
	x_dist_control.amount_ordered_change	:=0; --<R12 Requester Driven Procurement>

	/* This package is shared by PO and Release
	 * Pre-condition: Either po_header_id or po_release_id is NULL
	 */

	x_po_header_id	  := x_dist_parameters.po_header_id;
	x_po_release_id	  := x_dist_parameters.po_release_id;

	IF ((x_po_header_id IS NOT NULL AND x_po_release_id IS NOT NULL) OR
	    (x_po_header_id IS NULL AND x_po_release_id IS NULL)) THEN
		raise e_invalid_setup;
	END IF;

/*bug# 880416: changes from 110.5 -
  csheu bug #875995: split the old SQLs based on x_po_header_id */

      -- SQL What: Select 'Y' if distribution number is changed
      -- SQL Why: Need the value for routing to reapproval
      --          if there is a change
      -- SQL Join: po_distribution_id, distribution_num
        IF (x_po_header_id IS NOT NULL) THEN
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.distribution_num
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.distribution_num <> PODA.distribution_num)
                OR (POD.distribution_num IS NULL
                        AND PODA.distribution_num IS NOT NULL)
                OR (POD.distribution_num IS NOT NULL
                        AND PODA.distribution_num IS NULL)
	       			)
		-- <Encumbrance FPJ>
		AND POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.distribution_num := 'N';
        END;
      ELSE
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.distribution_num
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.distribution_num <> PODA.distribution_num)
                OR (POD.distribution_num IS NULL
                        AND PODA.distribution_num IS NOT NULL)
                OR (POD.distribution_num IS NOT NULL
                        AND PODA.distribution_num IS NULL)
	       );
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.distribution_num := 'N';
        END;
      END IF;

      -- SQL What: Select 'Y' if deliver to person is changed
      -- SQL Why: Need the value for routing to reapproval
      --          if there is a change
      -- SQL Join: po_distribution_id, deliver_to_person_id
      IF (x_po_header_id IS NOT NULL) THEN
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.deliver_to_person_id
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.deliver_to_person_id <> PODA.deliver_to_person_id)
                OR (POD.deliver_to_person_id IS NULL
                        AND PODA.deliver_to_person_id IS NOT NULL)
                OR (POD.deliver_to_person_id IS NOT NULL
                        AND PODA.deliver_to_person_id IS NULL)
	       )
		-- <Encumbrance FPJ>
	       AND POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.deliver_to_person_id := 'N';
        END;
      ELSE
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.deliver_to_person_id
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.deliver_to_person_id <> PODA.deliver_to_person_id)
                OR (POD.deliver_to_person_id IS NULL
                        AND PODA.deliver_to_person_id IS NOT NULL)
                OR (POD.deliver_to_person_id IS NOT NULL
                        AND PODA.deliver_to_person_id IS NULL)
	       );
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.deliver_to_person_id := 'N';
        END;
      END IF;

      -- SQL What: Select 'Y' if rate date is changed
      -- SQL Why: Need the value for routing to reapproval
      --          if there is a change
      -- SQL Join: po_distribution_id, rate_date
      IF (x_po_header_id IS NOT NULL) THEN
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.rate_date
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.rate_date <> PODA.rate_date)
                OR (POD.rate_date IS NULL
                        AND PODA.rate_date IS NOT NULL)
                OR (POD.rate_date IS NOT NULL
                        AND PODA.rate_date IS NULL)
	       )
		-- <Encumbrance FPJ>
	       AND POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.rate_date := 'N';
        END;
      ELSE
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.rate_date
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.rate_date <> PODA.rate_date)
                OR (POD.rate_date IS NULL
                        AND PODA.rate_date IS NOT NULL)
                OR (POD.rate_date IS NOT NULL
                        AND PODA.rate_date IS NULL)
	       );
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.rate_date := 'N';
        END;
      END IF;

      -- SQL What: Select 'Y' if encumbered date is changed
      -- SQL Why: Need the value for routing to reapproval
      --          if there is a change
      -- SQL Join: po_distribution_id, gl_encumbered_date
      IF (x_po_header_id IS NOT NULL) THEN
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.gl_encumbered_date
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.gl_encumbered_date <> PODA.gl_encumbered_date)
                OR (POD.gl_encumbered_date IS NULL
                        AND PODA.gl_encumbered_date IS NOT NULL)
                OR (POD.gl_encumbered_date IS NOT NULL
                        AND PODA.gl_encumbered_date IS NULL)
	       )
		-- <Encumbrance FPJ>
               AND POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
 	WHEN NO_DATA_FOUND THEN
		x_dist_control.gl_encumbered_date := 'N';
        END;
      ELSE
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.gl_encumbered_date
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.gl_encumbered_date <> PODA.gl_encumbered_date)
                OR (POD.gl_encumbered_date IS NULL
                        AND PODA.gl_encumbered_date IS NOT NULL)
                OR (POD.gl_encumbered_date IS NOT NULL
                        AND PODA.gl_encumbered_date IS NULL)
	       );
        EXCEPTION
 	WHEN NO_DATA_FOUND THEN
		x_dist_control.gl_encumbered_date := 'N';
        END;

      END IF;

      -- SQL What: Select 'Y' if code_combination_id is changed
      -- SQL Why: Need the value for routing to reapproval
      --          if there is a change
      -- SQL Join: po_distribution_id, code_combination_id
      IF (x_po_header_id IS NOT NULL) THEN
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.code_combination_id
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.code_combination_id <> PODA.code_combination_id)
                OR (POD.code_combination_id IS NULL
                        AND PODA.code_combination_id IS NOT NULL)
                OR (POD.code_combination_id IS NOT NULL
                        AND PODA.code_combination_id IS NULL)
	       			)
		-- <Encumbrance FPJ>
	       	AND POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.code_combination_id := 'N';
        END;
      ELSE
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.code_combination_id
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.code_combination_id <> PODA.code_combination_id)
                OR (POD.code_combination_id IS NULL
                        AND PODA.code_combination_id IS NOT NULL)
                OR (POD.code_combination_id IS NOT NULL
                        AND PODA.code_combination_id IS NULL)
	       );
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.code_combination_id := 'N';
        END;

      END IF;

      -- SQL What: Select 'Y' if destination subinventory is changed
      -- SQL Why: Need the value for routing to reapproval
      --          if there is a change
      -- SQL Join: po_distribution_id, destination_subinventory
      IF (x_po_header_id IS NOT NULL) THEN
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.destination_subinventory
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.destination_subinventory <> PODA.destination_subinventory)
                OR (POD.destination_subinventory IS NULL
                        AND PODA.destination_subinventory IS NOT NULL)
                OR (POD.destination_subinventory IS NOT NULL
                        AND PODA.destination_subinventory IS NULL)
	       )
		-- <Encumbrance FPJ>
	       AND POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.destination_subinventory := 'N';
        END;
      ELSE
        BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_dist_control.destination_subinventory
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                   (PODA.po_distribution_id is NULL)
                OR (POD.destination_subinventory <> PODA.destination_subinventory)
                OR (POD.destination_subinventory IS NULL
                        AND PODA.destination_subinventory IS NOT NULL)
                OR (POD.destination_subinventory IS NOT NULL
                        AND PODA.destination_subinventory IS NULL)
	       );
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.destination_subinventory := 'N';
        END;
      END IF;

      -- SQL What: Retrieving the percentage change in quantity ordered
      -- SQL Why: Need the value in tolerance check (i.e reapproval
      --          rule validations)
      -- SQL Join: po_distribution_id
      IF (x_po_header_id IS NOT NULL) THEN
        BEGIN

	       SELECT max(po_chord_wf0.percentage_change(
			 PODA.quantity_ordered, POD.quantity_ordered))
               INTO  x_dist_control.quantity_ordered_change
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
		-- <Encumbrance FPJ>
	       AND   POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.quantity_ordered_change := 0;
        END;
      ELSE
        BEGIN

	       SELECT max(po_chord_wf0.percentage_change(
			 PODA.quantity_ordered, POD.quantity_ordered))
               INTO  x_dist_control.quantity_ordered_change
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y';
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_dist_control.quantity_ordered_change := 0;
        END;
      END IF;

      -- SQL What: Retrieving the percentage change in rate
      -- SQL Why: Need the value in tolerance check (i.e reapproval
      --          rule validations)
      -- SQL Join: po_distribution_id
      IF (x_po_header_id IS NOT NULL) THEN
        BEGIN
	       SELECT max(po_chord_wf0.percentage_change(
			 PODA.rate, POD.rate))
               INTO  x_dist_control.rate_change
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_header_id = x_po_header_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
		-- <Encumbrance FPJ>
	       AND   POD.distribution_type <> 'AGREEMENT';
        EXCEPTION
 	WHEN NO_DATA_FOUND THEN
		x_dist_control.rate_change := 0;
        END;
      ELSE
        BEGIN

	       SELECT max(po_chord_wf0.percentage_change(
			 PODA.rate, POD.rate))
               INTO  x_dist_control.rate_change
               FROM  PO_DISTRIBUTIONS_ALL POD,
                     PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
               WHERE
		     POD.po_release_id = x_po_release_id
               AND   POD.po_distribution_id = PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y';
        EXCEPTION
 	WHEN NO_DATA_FOUND THEN
		x_dist_control.rate_change := 0;
        END;

      END IF;

      --<R12 Requester Driven Procurement Start>

      -- SQL What: Retrieving the percentage change in amount ordered
      -- SQL Why: Need the value in tolerance check (i.e reapproval
      --          rule validations)
      -- SQL Join: po_distribution_id
      -- Bug 5071741: Amount change is calculated using price and qty for
      -- qty based lines and amount for services lines and rounded accordingly
      IF (x_po_header_id IS NOT NULL) THEN

          -- Get the currency code and precision
          SELECT poh.currency_code
          INTO   l_currency_code
          FROM   po_headers_all poh
          WHERE  poh.po_header_id = x_po_header_id;

          PO_CORE_S2.get_currency_info(
            x_currency_code => l_currency_code
          , x_min_unit      => l_min_acct_unit
          , x_precision     => l_precision);

        BEGIN

         IF l_min_acct_unit is not null AND
            l_min_acct_unit <> 0 THEN

	   SELECT max(po_chord_wf0.percentage_change(
                round (
		 decode(POLLA.value_basis, 'RATE',PODA.amount_ordered,'FIXED PRICE', PODA.amount_ordered,
                       (PODA.quantity_ordered*POLLA.price_override))/ l_min_acct_unit )* l_min_acct_unit ,
                round (
                 decode(POLL.value_basis, 'RATE',POD.amount_ordered,'FIXED PRICE', POD.amount_ordered,
                       (POD.quantity_ordered*POLL.price_override)) / l_min_acct_unit )* l_min_acct_unit
              ))
           INTO  x_dist_control.amount_ordered_change
           FROM  PO_DISTRIBUTIONS_ALL POD,
                 PO_DISTRIBUTIONS_ARCHIVE_ALL PODA,
                 PO_LINE_LOCATIONS_ALL POLL,
                 PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
           WHERE POD.po_header_id = x_po_header_id
             AND POD.po_distribution_id = PODA.po_distribution_id (+)
             AND PODA.latest_external_flag (+) = 'Y'
             AND POD.distribution_type <> 'AGREEMENT'
             AND POD.line_location_id = POLL.line_location_id       -- Bug 5071741
             AND PODA.line_location_id = POLLA.line_location_id     -- Bug 5071741
             AND POLL.line_location_id = POLLA.line_location_id (+) -- Bug 5071741
             AND POLLA.latest_external_flag (+) = 'Y'               -- Bug 5071741
             AND POLL.po_release_id is NULL;                        -- Bug 5071741

          ELSE
             SELECT max(po_chord_wf0.percentage_change(
                round (
		 decode(POLLA.value_basis, 'RATE',PODA.amount_ordered,'FIXED PRICE', PODA.amount_ordered,
                       (PODA.quantity_ordered*POLLA.price_override)), l_precision ) ,
                round (
                 decode(POLL.value_basis, 'RATE',POD.amount_ordered,'FIXED PRICE', POD.amount_ordered,
                       (POD.quantity_ordered*POLL.price_override)) , l_precision )
              ))
           INTO  x_dist_control.amount_ordered_change
           FROM  PO_DISTRIBUTIONS_ALL POD,
                 PO_DISTRIBUTIONS_ARCHIVE_ALL PODA,
                 PO_LINE_LOCATIONS_ALL POLL,
                 PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
           WHERE POD.po_header_id = x_po_header_id
             AND POD.po_distribution_id = PODA.po_distribution_id (+)
             AND PODA.latest_external_flag (+) = 'Y'
             AND POD.distribution_type <> 'AGREEMENT'
             AND POD.line_location_id = POLL.line_location_id       -- Bug 5071741
             AND PODA.line_location_id = POLLA.line_location_id     -- Bug 5071741
             AND POLL.line_location_id = POLLA.line_location_id (+) -- Bug 5071741
             AND POLLA.latest_external_flag (+) = 'Y'               -- Bug 5071741
             AND POLL.po_release_id is NULL;                        -- Bug 5071741
          END IF;

        EXCEPTION
 	  WHEN NO_DATA_FOUND THEN
	    x_dist_control.amount_ordered_change := 0;
        END;

      ELSE -- po_header_id null : release

          -- Get the currency code and precision
          SELECT poh.currency_code
          INTO   l_currency_code
          FROM   po_releases_all por,
                 po_headers_all poh
          WHERE  por.po_release_id = x_po_release_id
          AND    poh.po_header_id = por.po_header_id;

          PO_CORE_S2.get_currency_info(
            x_currency_code => l_currency_code
          , x_min_unit      => l_min_acct_unit
          , x_precision     => l_precision);

        BEGIN

         IF l_min_acct_unit is not null AND
            l_min_acct_unit <> 0 THEN

           SELECT max(po_chord_wf0.percentage_change(
                round (
		 decode(POLLA.value_basis,'FIXED PRICE', PODA.amount_ordered,
                       (PODA.quantity_ordered*POLLA.price_override))/ l_min_acct_unit )* l_min_acct_unit ,
                round (
                 decode(POLL.value_basis, 'FIXED PRICE', POD.amount_ordered,
                       (POD.quantity_ordered*POLL.price_override)) / l_min_acct_unit )* l_min_acct_unit
              ))
           INTO  x_dist_control.amount_ordered_change
           FROM  PO_DISTRIBUTIONS_ALL POD,
                 PO_DISTRIBUTIONS_ARCHIVE_ALL PODA,
                 PO_LINE_LOCATIONS_ALL POLL,
                 PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
           WHERE POD.po_release_id = x_po_release_id
             AND POD.po_distribution_id = PODA.po_distribution_id (+)
             AND PODA.latest_external_flag (+) = 'Y'
             AND POD.line_location_id = POLL.line_location_id       -- Bug 5071741
             AND PODA.line_location_id = POLLA.line_location_id     -- Bug 5071741
             AND POLL.line_location_id = POLLA.line_location_id (+) -- Bug 5071741
             AND POLLA.latest_external_flag (+) = 'Y';              -- Bug 5071741

        ELSE

          SELECT max(po_chord_wf0.percentage_change(
                round (
		 decode(POLLA.value_basis,'FIXED PRICE', PODA.amount_ordered,
                       (PODA.quantity_ordered*POLLA.price_override)) , l_precision ) ,
                round (
                 decode(POLL.value_basis, 'FIXED PRICE', POD.amount_ordered,
                       (POD.quantity_ordered*POLL.price_override)) , l_precision )
              ))
           INTO  x_dist_control.amount_ordered_change
           FROM  PO_DISTRIBUTIONS_ALL POD,
                 PO_DISTRIBUTIONS_ARCHIVE_ALL PODA,
                 PO_LINE_LOCATIONS_ALL POLL,
                 PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
           WHERE POD.po_release_id = x_po_release_id
             AND POD.po_distribution_id = PODA.po_distribution_id (+)
             AND PODA.latest_external_flag (+) = 'Y'
             AND POD.line_location_id = POLL.line_location_id       -- Bug 5071741
             AND PODA.line_location_id = POLLA.line_location_id     -- Bug 5071741
             AND POLL.line_location_id = POLLA.line_location_id (+) -- Bug 5071741
             AND POLLA.latest_external_flag (+) = 'Y';              -- Bug 5071741

        END IF;

        EXCEPTION
 	  WHEN NO_DATA_FOUND THEN
	    x_dist_control.amount_ordered_change := 0;
        END;
      END IF;

      --<R12 Requester Driven Procurement End>

   --debug_dist_control(itemtype, itemkey, x_dist_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: check_dist_change ***' );
	END IF;

EXCEPTION
	WHEN e_invalid_setup THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** exception check_dist_change ***');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_dist_control', 'e_invalid_setup');
	raise;

	WHEN others THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** exeption: check_dist_change ***');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_dist_control', 'others');
	raise;

END;

PROCEDURE set_wf_dist_control( itemtype	IN VARCHAR2,
				        itemkey 	IN VARCHAR2,
					x_dist_control IN t_dist_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure:set_wf_dist_control  ***' );
	END IF;

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_DIST_NUM',
			   x_dist_control.distribution_num);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_DELIVER_TO_PERSON',
			   x_dist_control.deliver_to_person_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_RATE_DATE',
			   x_dist_control.rate_date);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_GL_ENCUMBERED_DATE',
			   x_dist_control.gl_encumbered_date);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_CHARGE_ACCOUNT',
			   x_dist_control.code_combination_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_DEST_SUBINVENTORY',
			   x_dist_control.destination_subinventory);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_DEST_SUBINVENTORY',
			   x_dist_control.destination_subinventory);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_D_QUANTITY_ORDERED_CHANGE',
			     x_dist_control.quantity_ordered_change);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_D_RATE_CHANGE',
			     x_dist_control.rate_change);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_D_AMOUNT_ORDERED_CHANGE',
                           x_dist_control.amount_ordered_change); --<R12 Requester Driven Procurement>

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish:set_wf_dist_control  ***' );
	END IF;
EXCEPTION
	WHEN others THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** exeption: set_wf_dist_control ***');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_dist_control', 'others');
	raise;

END;


PROCEDURE get_wf_dist_control( itemtype	IN VARCHAR2,
				       itemkey 	IN VARCHAR2,
				       x_dist_control IN OUT NOCOPY t_dist_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure :get_wf_dist_control  ***' );
	END IF;

 x_dist_control.distribution_num:=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_DIST_NUM');

 x_dist_control.deliver_to_person_id:=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_DELIVER_TO_PERSON');

 x_dist_control.rate_date :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_RATE_DATE');

 x_dist_control.gl_encumbered_date :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_GL_ENCUMBERED_DATE');

 x_dist_control.code_combination_id :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_CHARGE_ACCOUNT');

 x_dist_control.destination_subinventory :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_D_DEST_SUBINVENTORY');

 x_dist_control.quantity_ordered_change :=
 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_D_QUANTITY_ORDERED_CHANGE');

 x_dist_control.rate_change :=
 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_D_RATE_CHANGE');

 x_dist_control.amount_ordered_change :=
     PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_D_AMOUNT_ORDERED_CHANGE'); --<R12 Requester Driven Procurement>

 debug_dist_control(itemtype, itemkey, x_dist_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: get_wf_dist_control  ***' );
	END IF;

END;

PROCEDURE get_wf_dist_parameters(itemtype	 IN VARCHAR2,
				 itemkey 	 IN VARCHAR2,
			 	 x_dist_parameters IN OUT NOCOPY t_dist_parameters_type)
IS
	x_doc_type		VARCHAR2(25);
	e_invalid_doc_type	EXCEPTION;
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure get_wf_dist_parameters ***');
	END IF;

  	x_doc_type := wf_engine.GetItemAttrText (itemtype,
                                                 itemkey,
                                         	 'DOCUMENT_TYPE');

	IF x_doc_type IN ('PO', 'PA') THEN

 		x_dist_parameters.po_header_id :=
		wf_engine.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

		x_dist_parameters.po_release_id:=NULL;

        ELSIF x_doc_type = 'RELEASE' THEN

 		x_dist_parameters.po_release_id :=
		wf_engine.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

		x_dist_parameters.po_header_id:=NULL;

	ELSE
		raise e_invalid_doc_type;

	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'po_header_id =  ' || to_char(x_dist_parameters.po_header_id));
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'po_release_id =  '|| to_char(x_dist_parameters.po_release_id));
	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** FINISH: get_wf_dist_parameters ***');
	END IF;

EXCEPTION
 WHEN e_invalid_doc_type THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'***set_wf_dist_parameters exception e_invalid_setup *** ');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_dist_control', 'e_invalid_setup');
	raise;

 WHEN OTHERS THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'***set_wf_dist_parameters exception  *** ');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_dist_control', 'others');
	raise;


END;



PROCEDURE debug_dist_control(
		itemtype IN VARCHAR2,
		itemkey  IN VARCHAR2,
		x_dist_control IN t_dist_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: debug_dist_control ***' );
	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'distribution_num         : '|| x_dist_control.distribution_num);
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'deliver_to_person_id     : '|| x_dist_control.deliver_to_person_id);
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'rate_date                : '|| x_dist_control.rate_date);
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'gl_encumbered_date       : '|| x_dist_control.gl_encumbered_date);
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'code_combination_id      : '|| x_dist_control.code_combination_id);
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'destination_subinventory : '|| x_dist_control.destination_subinventory);
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'quantity_ordered_change  : '|| to_char(x_dist_control.quantity_ordered_change));
   	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   		'amount_ordered_change  : '|| to_char(x_dist_control.amount_ordered_change)); --<R12 Requester Driven Procurement>
	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished:  debug_dist_control **' );
	END IF;

END;


END PO_CHORD_WF4;

/
