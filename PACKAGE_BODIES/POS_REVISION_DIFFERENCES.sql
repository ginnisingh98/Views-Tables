--------------------------------------------------------
--  DDL for Package Body POS_REVISION_DIFFERENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_REVISION_DIFFERENCES" AS
/* $Header: POSPORVB.pls 120.1 2006/07/15 00:53:31 abtrived noship $ */

/*********************************************************************
 * NAME
 * compare_po_to_all
 *
 * PURPOSE
 * Call the procedure COMPARE_PO with ALL as comparison flag.
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the current PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_dummy_in4		Not required
 * p_dummy_in5		Not required
 * p_dummy_in6		Not required
 * p_dummy_in7		Not required
 * p_dummy_in8		Not required
 * p_dummy_in9		Not required
 * p_dummy_in10		Not required
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 * p_dummy_out2		Not required
 * p_dummy_out3		Not required
 * p_dummy_out4		Not required
 * p_dummy_out5		Not required
 * p_dummy_out6		Not required
 * p_dummy_out7		Not required
 * p_dummy_out8		Not required
 * p_dummy_out9		Not required
 * p_dummy_out10	Not required
 *
 * NOTES
 * This procedures serves the purpose of a link from WAD to call the
 * procedure COMPARE_PO.  There is no way to store the comparison flag
 * in the link.  Therefore, the link calls this procedure, which calls
 * COMPARE_PO with the appropriate flag.
 *
 * Normally, you do not want to call this procedure directly.  You can
 * simply call COMPARE_PO with the appropriate parameters.
 *
 * HISTORY
 * 20-NOV-1997	Rami Haddad	Created
 ********************************************************************/
PROCEDURE compare_po_to_all(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '010';
compare_po(
	p_header_id,
	p_release_id,
	p_revision_num,
	'ALL',
	v_sequence_num );

p_sequence_num := v_sequence_num;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_TO_ALL',
		v_progress,
		sqlcode );
	RAISE;

END compare_po_to_all;



/*********************************************************************
 * NAME
 * compare_po_to_original
 *
 * PURPOSE
 * Call the procedure COMPARE_PO with the ORIGINAL as comparison flag.
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the current PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_dummy_in4		Not required
 * p_dummy_in5		Not required
 * p_dummy_in6		Not required
 * p_dummy_in7		Not required
 * p_dummy_in8		Not required
 * p_dummy_in9		Not required
 * p_dummy_in10		Not required
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 * p_dummy_out2		Not required
 * p_dummy_out3		Not required
 * p_dummy_out4		Not required
 * p_dummy_out5		Not required
 * p_dummy_out6		Not required
 * p_dummy_out7		Not required
 * p_dummy_out8		Not required
 * p_dummy_out9		Not required
 * p_dummy_out10	Not required
 *
 * NOTES
 * This procedures serves the purpose of a link from WAD to call the
 * procedure COMPARE_PO.  There is no way to store the comparison flag
 * in the link.  Therefore, the link calls this procedure, which calls
 * COMPARE_PO with the appropriate flag.
 *
 * Normally, you do not want to call this procedure directly.  You can
 * simply call COMPARE_PO with the appropriate parameters.
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 ********************************************************************/
PROCEDURE compare_po_to_original(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '020';

compare_po(
	p_header_id,
	p_release_id,
	p_revision_num,
	'ORIGINAL',
	v_sequence_num );

p_sequence_num := v_sequence_num;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_TO_ORIGINAL',
		v_progress,
		sqlcode );
	RAISE;

END compare_po_to_original;



/*********************************************************************
 * NAME
 * compare_po_to_previous
 *
 * PURPOSE
 * Call the procedure COMPARE_PO with the PREVIOUS as comparison flag.
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the current PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_dummy_in4		Not required
 * p_dummy_in5		Not required
 * p_dummy_in6		Not required
 * p_dummy_in7		Not required
 * p_dummy_in8		Not required
 * p_dummy_in9		Not required
 * p_dummy_in10		Not required
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 * p_dummy_out2		Not required
 * p_dummy_out3		Not required
 * p_dummy_out4		Not required
 * p_dummy_out5		Not required
 * p_dummy_out6		Not required
 * p_dummy_out7		Not required
 * p_dummy_out8		Not required
 * p_dummy_out9		Not required
 * p_dummy_out10	Not required
 *
 * NOTES
 * This procedures serves the purpose of a link from WAD to call the
 * procedure COMPARE_PO.  There is no way to store the comparison flag
 * in the link.  Therefore, the link calls this procedure, which calls
 * COMPARE_PO with the appropriate flag.
 *
 * Normally, you do not want to call this procedure directly.  You can
 * simply call COMPARE_PO with the appropriate parameters.
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 ********************************************************************/
PROCEDURE compare_po_to_previous(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '030';

compare_po(
	p_header_id,
	p_release_id,
	p_revision_num,
	'PREVIOUS',
	v_sequence_num );

p_sequence_num := v_sequence_num;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_TO_PREVIOUS',
		v_progress,
		sqlcode );
	RAISE;

END compare_po_to_previous;


/*********************************************************************
 * NAME
 * compare_po_to_lastsign
 *
 * PURPOSE
 * Call the procedure COMPARE_PO with the LASTSIGN as comparison flag.
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the current PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_dummy_in4		Not required
 * p_dummy_in5		Not required
 * p_dummy_in6		Not required
 * p_dummy_in7		Not required
 * p_dummy_in8		Not required
 * p_dummy_in9		Not required
 * p_dummy_in10		Not required
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 * p_dummy_out2		Not required
 * p_dummy_out3		Not required
 * p_dummy_out4		Not required
 * p_dummy_out5		Not required
 * p_dummy_out6		Not required
 * p_dummy_out7		Not required
 * p_dummy_out8		Not required
 * p_dummy_out9		Not required
 * p_dummy_out10	Not required
 *
 * NOTES
 * This procedures serves the purpose of a link from WAD to call the
 * procedure COMPARE_PO.  There is no way to store the comparison flag
 * in the link.  Therefore, the link calls this procedure, which calls
 * COMPARE_PO with the appropriate flag.
 *
 * Normally, you do not want to call this procedure directly.  You can
 * simply call COMPARE_PO with the appropriate parameters.
 *
 * HISTORY
 * 12-SEP-2003	ammitra   created
 ********************************************************************/
PROCEDURE compare_po_to_lastsign(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '030';

compare_po(
	p_header_id,
	p_release_id,
	p_revision_num,
	'LASTSIGN',
	v_sequence_num );

p_sequence_num := v_sequence_num;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_TO_PREVIOUS',
		v_progress,
		sqlcode );
	RAISE;

END compare_po_to_lastsign;


/*********************************************************************
 * NAME
 * compare_po
 *
 * PURPOSE
 * Compare the a PO with the previous or the original
 * revision---including all lines, shipments, and distributions.
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the current PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 25-NOV-1997	Rami Haddad	Handle comparison flag 'ALL,' which
 *				loops through and compare all
 *				revisions.
 ********************************************************************/
PROCEDURE compare_po(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num OUT NOCOPY NUMBER
	) AS

v_sequence_num		NUMBER;
v_revision_counter	NUMBER := p_revision_num;
v_comparison_flag	VARCHAR2( 80 ) := p_comparison_flag;
v_progress		VARCHAR2(3);
l_last_sign_revision    NUMBER;
x_base_revision         NUMBER;
x_global_agree_flag     varchar2(1);

BEGIN

v_progress := '040';

SELECT	icx_po_history_details_s.nextval
INTO	v_sequence_num
FROM	DUAL;
p_sequence_num := v_sequence_num;


select nvl(global_agreement_flag,'N')
into   x_global_agree_flag
from   po_headers_all
where  po_header_id = p_header_id;

IF v_comparison_flag = 'ALL'  then
	v_comparison_flag := 'PREVIOUS';
	x_base_revision := 1;
END IF;

LOOP
	v_progress := '050';
	compare_headers(
		p_header_id,
		p_release_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num ,
		p_comparison_flag);

	if (x_global_agree_flag = 'Y')  then
		compare_ga_assignments(
			p_header_id,
			v_revision_counter,
			v_comparison_flag,
			v_sequence_num );
	end if;

	v_progress := '060';

-- Bug# 1761302. Added the IF THEN condition as there is
-- no change in lines for revisions against Releases.

        IF (p_release_id is NULL) THEN
	compare_lines(
		p_header_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num);
         END IF;


	compare_pdiffs_line(
		p_header_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num);


	compare_pdiffs_ship(
		p_header_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num);



	v_progress := '070';
	compare_locations(
		p_header_id,
		p_release_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num);

	v_progress := '080';

	-- forward port 5392285 - comparing distributions
	--bug # 366756 not comparing distribututions

	compare_distributions(
		p_header_id,
		p_release_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num);



	v_revision_counter := v_revision_counter - 1;

	IF (v_revision_counter < x_base_revision) OR
           (p_comparison_flag  <> 'ALL')

	THEN
		EXIT;
	END IF;

END LOOP;

v_progress := '090';
pos_compare_revisions.verify_no_differences( v_sequence_num );

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO',
		v_progress,
		sqlcode );
	RAISE;

END compare_po;



/*********************************************************************
 * NAME
 * compare_headers
 *
 * PURPOSE
 * Compare two headers, the first is according to the passed in
 * parameters, P_HEADER_ID and P_REVISION_NUM.  The second depends on
 * the comparison flag, either the original PO (revision 0), or the
 * previous revision (P_REVISION_NUM - 1 ).
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 ********************************************************************/
PROCEDURE compare_headers(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER,
	p_comparison_flag_org IN VARCHAR2
	) AS

v_header_from		po_headers_archive_all%ROWTYPE;
v_header_to		po_headers_archive_all%ROWTYPE;

v_release_from		po_releases_archive_all%ROWTYPE;
v_release_to		po_releases_archive_all%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);
l_msg_data              varchar2(2000);
l_msg_count             number;
l_revision_num          number;
l_signed_records        varchar2(20);
l_return_status         varchar2(20);
get_lastsign_rev_failed exception;

BEGIN

v_progress := '100';

IF p_revision_num <= 0
THEN
	RETURN;
END IF;

/* What is the revision number we will compare against? */
IF p_comparison_flag = 'ORIGINAL'
THEN
	v_previous_revision_num := 0;
ELSIF p_comparison_flag = 'LASTSIGN' then

  PO_CONTERMS_UTL_GRP.get_last_signed_revision(
  p_api_version         =>   1.0,
  p_init_msg_list       =>   FND_API.G_FALSE,
  p_header_id           =>   p_header_id,
  p_revision_num        =>   p_revision_num,
  x_signed_revision_num =>   l_revision_num,
  x_signed_records      =>   l_signed_records,
  x_return_status       =>   l_return_status,
  x_msg_data            =>   l_msg_data,
  x_msg_count           =>   l_msg_count);

 if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
  v_previous_revision_num := l_revision_num;
 else
   raise get_lastsign_rev_failed;
 end if;

ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

IF p_release_id IS NULL THEN

	BEGIN

		v_progress := '110';
		SELECT	*
		INTO	v_header_to
		FROM	po_headers_archive_all
		WHERE
			po_header_id = p_header_id
		AND	revision_num = p_revision_num;

		EXCEPTION
		WHEN no_data_found THEN
			v_header_to := NULL;

	END;

	BEGIN

		v_progress := '120';
		SELECT	*
		INTO	v_header_from
		FROM	po_headers_archive_all
		WHERE
			po_header_id = p_header_id
		AND	revision_num = v_previous_revision_num;

		EXCEPTION
		WHEN no_data_found THEN
			v_header_from := NULL;

	END;

	v_progress := '130';
	pos_compare_revisions.compare_headers(
		v_header_from,
		v_header_to,
		p_sequence_num,
		p_comparison_flag_org );

ELSE

	BEGIN

		v_progress := '140';
		SELECT	*
		INTO	v_release_to
		FROM	po_releases_archive_all
		WHERE
			po_release_id = p_release_id
		AND	revision_num = p_revision_num;

		EXCEPTION
		WHEN no_data_found THEN
			v_release_to := NULL;

	END;

	BEGIN

		v_progress := '150';
		SELECT	*
		INTO	v_release_from
		FROM	po_releases_archive_all
		WHERE
			po_release_id = p_release_id
		AND	revision_num = v_previous_revision_num;

		EXCEPTION
		WHEN no_data_found THEN
			v_release_from := NULL;

	END;

	v_progress := '160';
	pos_compare_revisions.compare_releases(
		v_release_from,
		v_release_to,
		p_sequence_num );

END IF;

EXCEPTION
 WHEN get_lastsign_rev_failed THEN
        PO_MESSAGE_S.SQL_ERROR(
                'PO_REVISION_DIFFERENCES.COMPARE_HEADERS',
                l_msg_data,
                sqlcode );
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_HEADERS',
		v_progress,
		sqlcode );
	RAISE;

END compare_headers;



/********************************************************************
* NAME
* compare_ga_assignments
* PURPOSE
* Compare Global Agreement Org Assignments for a Global Agreement
* ARGUMENTS
* p_header_id		Unique identified for the PO in
*			PO_HEADERS_ARCHIVE_ALL table
* p_release_id		Unique identifier for the PO release in
*			PO_RELEASES_ARCHIVE_ALL table
* p_revision_num	Current PO revision number
* p_comparison_flag	Indicator to compare the PO with the previous
*			or original revision
* p_sequence_num	Sequence number to identify the comparison
*			results for a specific record in
*			ICX_PO_REVISIONS_TEMP table.
*
* NOTES
*
* HISTORY
* 19-SEP-2003	Amitabh Mitra	Added
********************************************************************/

PROCEDURE compare_ga_assignments(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR	current_ga_assign_cursor(
	current_header_id NUMBER,
	current_revision_num NUMBER ) IS
SELECT 	*
FROM 	po_ga_org_assignments_archive pga1
WHERE
	po_header_id = current_header_id AND
	revision_num = (SELECT	MAX( revision_num )
	FROM	po_ga_org_assignments_archive pga2
	WHERE
		revision_num <= current_revision_num
	AND     pga2.organization_id = pga1.organization_id
	AND     pga2.po_header_id = pga1.po_header_id
	);


v_ga_ass_to	po_ga_org_assignments_archive%ROWTYPE;
v_ga_ass_from	po_ga_org_assignments_archive%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '270';

IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL'
THEN
	v_previous_revision_num := 0;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

FOR v_ga_ass_to IN current_ga_assign_cursor(
	p_header_id,
	p_revision_num
	) LOOP
	IF v_ga_ass_to.revision_num > v_previous_revision_num
	THEN

		BEGIN
		v_progress := '180';


		SELECT	*
		INTO	v_ga_ass_from
		FROM	po_ga_org_assignments_archive
		WHERE
			revision_num = (
			SELECT	MAX( revision_num )
			FROM   po_ga_org_assignments_archive
			WHERE
				revision_num <= v_previous_revision_num
			AND	organization_id = v_ga_ass_to.organization_id
			AND     po_header_id    = v_ga_ass_to.po_header_id
			)
		AND	organization_id = v_ga_ass_to.organization_id
		AND     po_header_id = v_ga_ass_to.po_header_id;

		EXCEPTION
		WHEN no_data_found THEN
			v_ga_ass_from := NULL;
		END;

		v_progress := '290';
		pos_compare_revisions.compare_ga_assignments(
			v_ga_ass_from,
			v_ga_ass_to,
			p_sequence_num);
	END IF;
   END LOOP;
EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_GA_ASSIGNMENTS',
		v_progress,
		sqlcode );
	RAISE;

END compare_ga_assignments;



/*********************************************************************
 * NAME
 * compare_lines
 *
 * PURPOSE
 * Compare lines for two POs, the first is according to the passed in
 * parameters, P_HEADER_ID and P_REVISION_NUM.  The second depends on
 * the comparison flag, either the original PO (revision 0), or the
 * previous revision (P_REVISION_NUM - 1 ).
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 20-NOV-1997	Rami Haddad	Changed cursor to select latest
 *				revision of lines for the PO, given
 *				its revision number, p_revision_num.
 ********************************************************************/
PROCEDURE compare_lines(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR	current_lines_cursor(
	current_header_id NUMBER,
	current_revision_num NUMBER ) IS
SELECT 	*
FROM 	po_lines_archive_all pla1
WHERE
	po_header_id = current_header_id
AND	revision_num = (
	SELECT	MAX( revision_num )
	FROM	po_lines_archive_all pla2
	WHERE
		revision_num <= current_revision_num
	AND	pla2.po_line_id = pla1.po_line_id
	);

v_line_to	po_lines_archive_all%ROWTYPE;
v_line_from	po_lines_archive_all%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '170';

IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL'
THEN
	v_previous_revision_num := 0;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

FOR v_line_to IN current_lines_cursor(
	p_header_id,
	p_revision_num
	) LOOP

	/* Compare the lines only if the current line has a revision
	 * greater than the calculated revision number of previous
	 * line.
	 */
	IF v_line_to.revision_num > v_previous_revision_num
	THEN

		BEGIN

		v_progress := '180';
		SELECT	*
		INTO	v_line_from
		FROM	po_lines_archive_all
		WHERE
			revision_num = (
			SELECT	MAX( revision_num )
			FROM	po_lines_archive_all
			WHERE
				revision_num <=
					v_previous_revision_num
			AND	po_line_id = v_line_to.po_line_id
			)
		AND	po_line_id = v_line_to.po_line_id;

		EXCEPTION
		WHEN no_data_found THEN
			v_line_from := NULL;

		END;

		v_progress := '190';
		pos_compare_revisions.compare_lines(
			v_line_from,
			v_line_to,
			p_sequence_num);
	END IF;

END LOOP;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_LINES',
		v_progress,
		sqlcode );
	RAISE;

END compare_lines;



PROCEDURE compare_pdiffs_line(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR	current_pdiffs_cursor(
	current_header_id NUMBER,
	current_revision_num NUMBER ) IS

SELECT 	PDIFF1.PRICE_DIFFERENTIAL_ID,
	PDIFF1.PRICE_DIFFERENTIAL_NUM,
	PDIFF1.ENTITY_ID           ,
	PDIFF1.ENTITY_TYPE         ,
	PDIFF1.PRICE_TYPE          ,
	PDIFF1.REVISION_NUM        ,
	PDIFF1.ENABLED_FLAG        ,
	PDIFF1.MIN_MULTIPLIER      ,
	PDIFF1.LATEST_EXTERNAL_FLAG,
	PDIFF1.MAX_MULTIPLIER      ,
	PDIFF1.MULTIPLIER          ,
	PDIFF1.CREATED_BY          ,
	PDIFF1.CREATION_DATE       ,
	PDIFF1.LAST_UPDATED_BY     ,
	PDIFF1.LAST_UPDATE_DATE    ,
	PDIFF1.LAST_UPDATE_LOGIN
FROM 	po_price_differentials_archive pdiff1,po_lines_all pol
WHERE
	pol.po_header_id = current_header_id and
	pol.po_line_id = pdiff1.entity_id and
 	revision_num = (
	SELECT	MAX( pdiff2.revision_num )
	FROM	po_price_differentials_archive pdiff2,
		po_lines_all  pol2
	WHERE
		pol2.po_header_id = current_header_id and
		pol2.po_line_id = pdiff2.entity_id and
		pdiff2.entity_type in ('PO LINE','BLANKET LINE') and
		pdiff2.revision_num <= current_revision_num
	AND	pdiff1.price_differential_id = pdiff2.price_differential_id
	);


v_pdiff_from	po_price_differentials_archive%ROWTYPE;
v_pdiff_to	po_price_differentials_archive%ROWTYPE;


v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '170';

IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL'
THEN
	v_previous_revision_num := 0;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;


FOR v_pdiff_to IN current_pdiffs_cursor(
	p_header_id,
	p_revision_num
	) LOOP

	IF v_pdiff_to.revision_num > v_previous_revision_num
	THEN
		BEGIN

		v_progress := '180';

		SELECT	*
		INTO	v_pdiff_from
		FROM	po_price_differentials_archive
		WHERE
			revision_num = (
			SELECT	MAX( revision_num )
			FROM	po_price_differentials_archive
			WHERE
				revision_num <= v_previous_revision_num
			AND	price_differential_id = v_pdiff_to.price_differential_id
			)
		AND	price_differential_id = v_pdiff_to.price_differential_id;

		EXCEPTION
		WHEN no_data_found THEN
			v_pdiff_from := NULL;

		END;

		v_progress := '190';
		pos_compare_revisions.compare_price_diffs(
			v_pdiff_from,
			v_pdiff_to,
			p_sequence_num);
	END IF;


END LOOP;
EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_LINES',
		v_progress,
		sqlcode );
	RAISE;

END compare_pdiffs_line;



PROCEDURE compare_pdiffs_ship(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR	current_pdiffs_cursor(
	current_header_id NUMBER,
	current_revision_num NUMBER ) IS

SELECT 	PDIFF1.PRICE_DIFFERENTIAL_ID,
	PDIFF1.PRICE_DIFFERENTIAL_NUM,
	PDIFF1.ENTITY_ID           ,
	PDIFF1.ENTITY_TYPE         ,
	PDIFF1.PRICE_TYPE          ,
	PDIFF1.REVISION_NUM        ,
	PDIFF1.ENABLED_FLAG        ,
	PDIFF1.MIN_MULTIPLIER      ,
	PDIFF1.LATEST_EXTERNAL_FLAG,
	PDIFF1.MAX_MULTIPLIER      ,
	PDIFF1.MULTIPLIER          ,
	PDIFF1.CREATED_BY          ,
	PDIFF1.CREATION_DATE       ,
	PDIFF1.LAST_UPDATED_BY     ,
	PDIFF1.LAST_UPDATE_DATE    ,
	PDIFF1.LAST_UPDATE_LOGIN
FROM 	po_price_differentials_archive pdiff1,po_line_locations_all pll
WHERE
	pll.po_header_id = current_header_id and
	pll.line_location_id = pdiff1.entity_id  and
 	revision_num = (
	SELECT	MAX( pdiff2.revision_num )
	FROM	po_price_differentials_archive pdiff2,
		po_line_locations_all  pll2
	WHERE
		pll2.po_header_id = current_header_id and
		pll2.line_location_id = pdiff2.entity_id and
		pdiff2.entity_type in ('PRICE BREAK') and
		pdiff2.revision_num <= current_revision_num  and
		pdiff1.price_differential_id = pdiff2.price_differential_id
	);


v_pdiff_from	po_price_differentials_archive%ROWTYPE;
v_pdiff_to	po_price_differentials_archive%ROWTYPE;


v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '170';

IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL'
THEN
	v_previous_revision_num := 0;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

FOR v_pdiff_to IN current_pdiffs_cursor(
	p_header_id,
	p_revision_num
	) LOOP

	IF v_pdiff_to.revision_num > v_previous_revision_num
	THEN
		BEGIN

		v_progress := '180';

		SELECT	*
		INTO	v_pdiff_from
		FROM	po_price_differentials_archive
		WHERE
			revision_num = (
			SELECT	MAX( revision_num )
			FROM	po_price_differentials_archive
			WHERE
				revision_num <= v_previous_revision_num
			AND	price_differential_id = v_pdiff_to.price_differential_id
			)
		AND	price_differential_id = v_pdiff_to.price_differential_id;

		EXCEPTION
		WHEN no_data_found THEN
			v_pdiff_from := NULL;

		END;

		pos_compare_revisions.compare_price_diffs(
			v_pdiff_from,
			v_pdiff_to,
			p_sequence_num);
	END IF;



END LOOP;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_LINES',
		v_progress,
		sqlcode );
	RAISE;

END compare_pdiffs_ship;




/*********************************************************************
 * NAME
 * compare_locations
 *
 * PURPOSE
 * Compare shipments for two POs, the first is according to the passed
 * in parameters, P_HEADER_ID and P_REVISION_NUM.  The second depends
 * on the comparison flag, either the original PO (revision 0), or the
 * previous revision (P_REVISION_NUM - 1 ).
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 20-NOV-1997	Rami Haddad	Changed cursor to select latest
 *				revision of shipments for the PO,
 *				given its revision number,
 *				p_revision_num.
 ********************************************************************/
PROCEDURE compare_locations(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR	current_locations_cursor(
		current_header_id NUMBER,
		current_release_id NUMBER,
		current_revision_num NUMBER ) IS
SELECT	*
FROM	po_line_locations_archive_all plla1
WHERE	po_header_id = current_header_id
AND	NVL( po_release_id, -99 ) = current_release_id
AND	revision_num = (
	SELECT	MAX( revision_num )
	FROM	po_line_locations_archive_all plla2
	WHERE
		revision_num <= current_revision_num
	AND	plla2.line_location_id = plla1.line_location_id
	);

v_loc_from		po_line_locations_archive_all%ROWTYPE;
v_loc_to		po_line_locations_archive_all%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '200';

IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL'
THEN
	v_previous_revision_num := 0;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

FOR v_loc_to in current_locations_cursor(
	p_header_id,
	NVL( p_release_id, -99 ),
	p_revision_num
	) LOOP

	/* Compare the lines only if the current line has a revision
 	 * greater than the calculated revision number of previous
	 * line.
	 */
	IF v_loc_to.revision_num > v_previous_revision_num THEN

		BEGIN

		v_progress := '210';
		SELECT	*
		INTO	v_loc_from
		FROM	po_line_locations_archive_all
		WHERE
			revision_num = (
			SELECT	MAX( revision_num )
			FROM	po_line_locations_archive_all
			WHERE
				revision_num <=
					v_previous_revision_num
			AND	line_location_id =
					v_loc_to.line_location_id
			)
		AND	line_location_id = v_loc_to.line_location_id;

		EXCEPTION
		WHEN no_data_found THEN
			v_loc_from := NULL;

		END;

		v_progress := '220';
		pos_compare_revisions.compare_locations(
			v_loc_from,
			v_loc_to,
			p_sequence_num );
		END IF;

END LOOP;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_LINES',
		v_progress,
		sqlcode );
	RAISE;

END compare_locations;



/*********************************************************************
 * NAME
 * compare_distributions
 *
 * PURPOSE
 * Compare distributions for two POs, the first is according to the
 * passed in parameters, P_HEADER_ID and P_REVISION_NUM.  The second
 * depends on the comparison flag, either the original PO (revision
 * 0), or the previous revision (P_REVISION_NUM - 1 ).
 *
 * ARGUMENTS
 * p_header_id		Unique identified for the PO in
 *			PO_HEADERS_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 20-NOV-1997	Rami Haddad	Changed cursor to select latest
 *				revision of distributions for the PO,
 *				given its revision number,
 *				p_revision_num.
 ********************************************************************/
PROCEDURE compare_distributions(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR	current_distributions_cursor(
	current_header_id NUMBER,
	current_release_id NUMBER,
	current_revision_num NUMBER
	) IS
SELECT	*
FROM	po_distributions_archive_all pda1
WHERE
	po_header_id = current_header_id
AND	NVL( po_release_id, -99 ) = current_release_id
AND	revision_num = (
	SELECT	MAX( revision_num )
	FROM	po_distributions_archive_all pda2
	WHERE
		revision_num <= current_revision_num
	AND	pda2.po_distribution_id = pda1.po_distribution_id
	);

v_dist_from		po_distributions_archive_all%ROWTYPE;
v_dist_to		po_distributions_archive_all%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '230';

IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL' THEN
	v_previous_revision_num := 0;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

FOR v_dist_to in current_distributions_cursor(
	p_header_id,
	NVL( p_release_id, -99 ),
	p_revision_num
	) LOOP

	/* Compare the lines only if the current line has a revision
	 * greater than the calculated revision number of previous
	 * line.
	 */
	IF v_dist_to.revision_num > v_previous_revision_num
	THEN

		BEGIN

		v_progress := '240';
		SELECT	*
		INTO	v_dist_from
		FROM	po_distributions_archive_all
		WHERE
			revision_num = (
			SELECT	MAX( revision_num )
			FROM	po_distributions_archive_all
			WHERE	revision_num <=
				v_previous_revision_num
			AND	po_distribution_id =
				v_dist_to.po_distribution_id
			)
		AND	po_distribution_id =
			v_dist_to.po_distribution_id;

		EXCEPTION
		WHEN no_data_found THEN
			v_dist_from := NULL;

		END;

		v_progress := '250';
		pos_compare_revisions.compare_distributions(
			v_dist_from,
			v_dist_to,
			p_sequence_num );
	END IF;

END LOOP;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_DISTRIBUTIONS',
		v_progress,
		sqlcode );
	RAISE;

END compare_distributions;



/*********************************************************************
 * NAME
 * compare_line_to_all
 *
 * PURPOSE
 * Call the procedure COMPARE_PO_LINE with ALL as comparison flag.
 *
 * ARGUMENTS
 * p_line_id		Unique identified for the current PO line in
 *			PO_LINES_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO line revision number
 * p_dummy_in4		Not required
 * p_dummy_in5		Not required
 * p_dummy_in6		Not required
 * p_dummy_in7		Not required
 * p_dummy_in8		Not required
 * p_dummy_in9		Not required
 * p_dummy_in10		Not required
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 * p_dummy_out2		Not required
 * p_dummy_out3		Not required
 * p_dummy_out4		Not required
 * p_dummy_out5		Not required
 * p_dummy_out6		Not required
 * p_dummy_out7		Not required
 * p_dummy_out8		Not required
 * p_dummy_out9		Not required
 * p_dummy_out10	Not required
 *
 * NOTES
 * This procedures serves the purpose of a link from WAD to call the
 * procedure COMPARE_PO_LINE.  There is no way to store the comparison
 * flag in the link.  Therefore, the link calls this procedure, which
 * calls COMPARE_PO_LINE with the appropriate flag.
 *
 * Normally, you do not want to call this procedure directly.  You can
 * simply call COMPARE_PO_LINE with the appropriate parameters.
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 ********************************************************************/
PROCEDURE compare_line_to_all(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '260';

compare_po_line(
	p_line_id,
	p_release_id,
	p_revision_num,
	'ALL',
	v_sequence_num );

p_sequence_num := v_sequence_num;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_LINE_TO_ALL',
		v_progress,
		sqlcode );
	RAISE;

END compare_line_to_all;



/*********************************************************************
 * NAME
 * compare_line_to_original
 *
 * PURPOSE
 * Call the procedure COMPARE_PO_LINE with the ORIGINAL as comparison
 * flag.
 *
 * ARGUMENTS
 * p_line_id		Unique identified for the current PO line in
 *			PO_LINES_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO line revision number
 * p_dummy_in4		Not required
 * p_dummy_in5		Not required
 * p_dummy_in6		Not required
 * p_dummy_in7		Not required
 * p_dummy_in8		Not required
 * p_dummy_in9		Not required
 * p_dummy_in10		Not required
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 * p_dummy_out2		Not required
 * p_dummy_out3		Not required
 * p_dummy_out4		Not required
 * p_dummy_out5		Not required
 * p_dummy_out6		Not required
 * p_dummy_out7		Not required
 * p_dummy_out8		Not required
 * p_dummy_out9		Not required
 * p_dummy_out10	Not required
 *
 * NOTES
 * This procedures serves the purpose of a link from WAD to call the
 * procedure COMPARE_PO_LINE.  There is no way to store the comparison
 * flag in the link.  Therefore, the link calls this procedure, which
 * calls COMPARE_PO_LINE with the appropriate flag.
 *
 * Normally, you do not want to call this procedure directly.  You can
 * simply call COMPARE_PO_LINE with the appropriate parameters.
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 ********************************************************************/
PROCEDURE compare_line_to_original(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '270';

compare_po_line(
	p_line_id,
	p_release_id,
	p_revision_num,
	'ORIGINAL',
	v_sequence_num );

p_sequence_num := v_sequence_num;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_TO_ORIGINAL',
		v_progress,
		sqlcode );
	RAISE;

END compare_line_to_original;



/*********************************************************************
 * NAME
 * compare_line_to_previous
 *
 * PURPOSE
 * Call the procedure COMPARE_PO_LINE with the PREVIOUS as comparison
 * flag.
 *
 * ARGUMENTS
 * p_line_id		Unique identified for the current PO line in
 *			PO_LINES_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO line revision number
 * p_dummy_in4		Not required
 * p_dummy_in5		Not required
 * p_dummy_in6		Not required
 * p_dummy_in7		Not required
 * p_dummy_in8		Not required
 * p_dummy_in9		Not required
 * p_dummy_in10		Not required
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 * p_dummy_out2		Not required
 * p_dummy_out3		Not required
 * p_dummy_out4		Not required
 * p_dummy_out5		Not required
 * p_dummy_out6		Not required
 * p_dummy_out7		Not required
 * p_dummy_out8		Not required
 * p_dummy_out9		Not required
 * p_dummy_out10	Not required
 *
 * NOTES
 * This procedures serves the purpose of a link from WAD to call the
 * procedure COMPARE_PO_LINE.  We need to have two links in the flow
 * to compare the PO line with the original or with the previous.
 * There is no way to store the comparison flag in the link.
 * Therefore, the link calls this procedure, which calls
 * COMPARE_PO_LINE with ORIGINAL flag.
 *
 * Normally, you do not want to call this procedure directly.  You can
 * simply call COMPARE_PO_LINE with the appropriate parameters.
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 ********************************************************************/
PROCEDURE compare_line_to_previous(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '280';

compare_po_line(
	p_line_id,
	p_release_id,
	p_revision_num,
	'PREVIOUS',
	v_sequence_num);

p_sequence_num := v_sequence_num;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_TO_PREVIOUS',
		v_progress,
		sqlcode );
	RAISE;

END compare_line_to_previous;



/*********************************************************************
 * NAME
 * compare_po_line
 *
 * PURPOSE
 * Compare a PO line with the previous or the original
 * revision---including all shipments, and distributions.
 *
 * ARGUMENTS
 * p_line_id		Unique identified for the current PO line in
 *			PO_LINES_ARCHIVE_ALL table
 * p_release_id		Unique identifier for the PO release in
 *			PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO line revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 26-NOV-1997	Rami Haddad	Handle comparison flag 'ALL.'
 ********************************************************************/
PROCEDURE compare_po_line(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num OUT NOCOPY NUMBER
	) AS

v_sequence_num	NUMBER := NULL;
v_revision_counter	NUMBER := p_revision_num;
v_comparison_flag	VARCHAR2( 80 ) := p_comparison_flag;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '290';
SELECT	icx_po_history_details_s.nextval
INTO	v_sequence_num
FROM	DUAL;
p_sequence_num := v_sequence_num;

v_progress := '300';
IF v_comparison_flag = 'ALL' THEN
	v_comparison_flag := 'PREVIOUS';
END IF;

LOOP
	v_progress := '310';

--Bug# 1788753.Adding the IF THEN condition.
      IF (p_release_id is NULL) THEN
	compare_line(
		p_line_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num );
       END IF;

	v_progress := '320';
	compare_line_locs(
		p_line_id,
		p_release_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num );

	v_progress := '330';
	compare_line_dists(
		p_line_id,
		p_release_id,
		v_revision_counter,
		v_comparison_flag,
		v_sequence_num );

	v_revision_counter := v_revision_counter - 1;

	IF v_revision_counter < 1 OR
		p_comparison_flag <>  'ALL'
	THEN
		EXIT;
	END IF;

END LOOP;

v_progress := '340';
pos_compare_revisions.verify_no_differences( v_sequence_num );

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_LINE',
		v_progress,
		sqlcode );
	RAISE;

END compare_po_line;



/*********************************************************************
 * NAME
 * compare_line
 *
 * PURPOSE
 * Compare a PO line with the previous or the original
 * revision---including all shipments, and distributions.
 *
 * ARGUMENTS
 * p_line_id		Unique identified for the current PO line in
 *			PO_LINES_ARCHIVE_ALL table
 * p_revision_num	Current PO line revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 * The original revision of a line is not necessarily 0.  When
 * comparing with the original, obtain the PO line with the lowest
 * revision.
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 24-NOV-1997	Rami Haddad	Select PO line with minimum revision
 *				as the original PO line, instead of
 *				the one with revision 0.
 ********************************************************************/
PROCEDURE compare_line(
	p_line_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

v_line_to		po_lines_archive_all%ROWTYPE;
v_line_from		po_lines_archive_all%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '350';
IF p_revision_num <= 0
THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL' THEN
	SELECT	MIN( revision_num )
	INTO	v_previous_revision_num
	FROM	po_lines_archive_all
	WHERE	po_line_id = p_line_id;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

BEGIN

	v_progress := '360';
	SELECT	*
	INTO	v_line_to
	FROM	po_lines_archive_all pla1
	WHERE
		po_line_id = p_line_id
	AND	revision_num = p_revision_num;

	EXCEPTION
	WHEN no_data_found THEN
		v_line_to := NULL;

END;

BEGIN

	v_progress := '370';
	SELECT	*
	INTO	v_line_from
	FROM	po_lines_archive_all
	WHERE
		po_line_id = p_line_id
	AND	revision_num = (
		SELECT	MAX( revision_num )
		FROM	po_lines_archive_all
		WHERE
			revision_num <=  v_previous_revision_num
		AND	po_line_id = p_line_id
		);

	EXCEPTION
	WHEN no_data_found THEN
		v_line_from := NULL;

END;

v_progress := '380';
pos_compare_revisions.compare_lines(
	v_line_from,
	v_line_to,
	p_sequence_num );

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_LINE',
		v_progress,
		sqlcode );
	RAISE;

END compare_line;



/*********************************************************************
 * NAME
 * compare_line_locs
 *
 * PURPOSE
 * Compare a PO line shipments with the previous or the original
 * revision---including all shipments, and distributions.
 *
 * ARGUMENTS
 * p_line_id		Unique identified for the current PO line in
 *			PO_LINES_ARCHIVE_ALL table
 * p_release_id		Unique identified for the current PO release
 *			in PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO line revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 20-NOV-1997	Rami Haddad	Changed cursor to select latest
 *				revision of shipments for the line,
 *				given its revision number,
 *				p_revision_num.
 ********************************************************************/
PROCEDURE compare_line_locs(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR current_locations(
	current_line_id NUMBER,
	current_release_id NUMBER
	) IS
SELECT	*
FROM	po_line_locations_archive_all plla1
WHERE
	po_line_id = current_line_id
AND	NVL( po_release_id, -99 ) = current_release_id
AND	revision_num = (
	SELECT	MAX( revision_num )
	FROM	po_line_locations_archive_all plla2
	WHERE
		revision_num <= p_revision_num
	AND	plla2.line_location_id = plla1.line_location_id
	);

v_loc_from		po_line_locations_archive_all%ROWTYPE;
v_loc_to		po_line_locations_archive_all%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '390';
IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL' THEN
	SELECT	MIN( revision_num )
	INTO	v_previous_revision_num
	FROM	po_lines_archive_all
	WHERE	po_line_id = p_line_id;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

v_progress := '400';
FOR v_loc_to IN current_locations(
	p_line_id,
	NVL( p_release_id, -99 )
	) loop

	/* Compare the lines only if the current line has a revision
	 * greater than the calculated revision number of previous
	 * line.
	 */
	IF v_loc_to.revision_num > v_previous_revision_num THEN

		BEGIN

		v_progress := '410';
		SELECT	*
		INTO	v_loc_from
		FROM	po_line_locations_archive_all
		WHERE
			line_location_id = v_loc_to.line_location_id
		AND	revision_num =
			(
			SELECT	MAX(revision_num)
			FROM	po_line_locations_archive_all
			WHERE
				revision_num <=
				v_previous_revision_num
			AND	line_location_id =
				v_loc_to.line_location_id
			);

			EXCEPTION
			WHEN no_data_found THEN
				v_loc_from := NULL;

		END;

		v_progress := '420';
		pos_compare_revisions.compare_locations(
			v_loc_from,
			v_loc_to,
			p_sequence_num );
	END IF;

END loop;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_LINE_LOCS',
		v_progress,
		sqlcode );
	RAISE;

END compare_line_locs;



/*********************************************************************
 * NAME
 * compare_line_dists
 *
 * PURPOSE
 * Compare a PO line distributions with the previous or the original
 * revision.
 *
 * ARGUMENTS
 * p_line_id		Unique identified for the current PO line in
 *			PO_LINES_ARCHIVE_ALL table
 * p_release_id		Unique identified for the current PO release
 *			in PO_RELEASES_ARCHIVE_ALL table
 * p_revision_num	Current PO line revision number
 * p_comparison_flag	Indicator to compare the PO with the previous
 *			or original revision
 * p_sequence_num	Sequence number to identify the comparison
 *			results for a specific record in
 *			ICX_PO_REVISIONS_TEMP table.
 *
 * NOTES
 *
 * HISTORY
 * 01-SEP-1997	Rami Haddad	Created
 * 05-SEP-1997	Matt Denton	Debugged
 * 20-NOV-1997	Rami Haddad	Documented
 *				Changed cursor to select latest
 *				revision of distributions for the
 *				line, given its revision number,
 *				p_revision_num.
 ********************************************************************/
PROCEDURE compare_line_dists(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) AS

CURSOR current_distributions(
	current_line_id number,
	current_release_id number
	) IS
SELECT	*
FROM	po_distributions_archive_all pda1
WHERE
	po_line_id = current_line_id
AND	NVL( po_release_id, -99 ) = current_release_id
AND	revision_num = (
	SELECT	MAX( revision_num )
	FROM	po_distributions_archive_all pda2
	WHERE
		revision_num <= p_revision_num
	AND	pda2.po_distribution_id = pda1.po_distribution_id
	);

v_dist_from		po_distributions_archive_all%ROWTYPE;
v_dist_to		po_distributions_archive_all%ROWTYPE;

v_previous_revision_num	NUMBER;
v_progress		VARCHAR2(3);

BEGIN

v_progress := '430';
IF p_revision_num <= 0 THEN
	RETURN;
END IF;

IF p_comparison_flag = 'ORIGINAL' THEN
	SELECT	MIN( revision_num )
	INTO	v_previous_revision_num
	FROM	po_lines_archive_all
	WHERE	po_line_id = p_line_id;
ELSE
	v_previous_revision_num :=  p_revision_num - 1;
END IF;

FOR v_dist_to in current_distributions(
	p_line_id,
	NVL( p_release_id, -99 )
	) LOOP

	/* Compare the lines only if the current line has a revision
	 * greater than the calculated revision number of previous
	 * line.
	 */
	IF v_dist_to.revision_num > v_previous_revision_num
	THEN

		BEGIN

		v_progress := '440';
		SELECT	*
		INTO	v_dist_from
		FROM	po_distributions_archive_all
		WHERE
			po_distribution_id =
				v_dist_to.po_distribution_id
		AND	revision_num = (
			SELECT	MAX( revision_num )
			FROM	po_distributions_archive_all
			WHERE	revision_num <=
				v_previous_revision_num
			AND	po_distribution_id =
				v_dist_to.po_distribution_id
			);

			EXCEPTION
			WHEN no_data_found THEN
				v_dist_from := NULL;

		END;

		v_progress := '450';
		pos_compare_revisions.compare_distributions(
			v_dist_from,
			v_dist_to,
			p_sequence_num );
		END IF;

END LOOP;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_REVISION_DIFFERENCES.COMPARE_PO_TO_ALL',
		v_progress,
		sqlcode );
	RAISE;

END compare_line_dists;

END pos_revision_differences;

/
