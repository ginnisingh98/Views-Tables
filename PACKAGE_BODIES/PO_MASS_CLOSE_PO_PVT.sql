--------------------------------------------------------
--  DDL for Package Body PO_MASS_CLOSE_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MASS_CLOSE_PO_PVT" AS
/* $Header: PO_Mass_Close_PO_PVT.plb 120.7.12010000.7 2012/05/08 07:30:09 yuandli ship $*/

g_debug_stmt                 CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp                CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_pkg_name                   CONSTANT VARCHAR2(100) := 'PO_Mass_Close_PO_PVT';
g_log_head                   CONSTANT VARCHAR2(1000) := 'po.plsql.' || g_pkg_name || '.';

TYPE g_close_po IS REF CURSOR;

TYPE g_close_rel IS REF CURSOR;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : po_close_documents.
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Calls the procedure po_actions.close_po to close the PO's and releases.

-- Parameters :

-- IN         : p_document_type        Type of the document(STANDARD,BLANKET.CONTRACT,PLANNED).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_supplier_id          Supplier id.
--		p_commit_interval      Commit interval.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE po_close_documents(p_document_type     IN VARCHAR2,
                             p_document_no_from  IN VARCHAR2,
                             p_document_no_to    IN VARCHAR2,
                             p_date_from         IN VARCHAR2,
                             p_date_to           IN VARCHAR2,
                             p_supplier_id       IN NUMBER,
			     p_commit_interval   IN NUMBER,
			     p_msg_data         OUT NOCOPY  VARCHAR2,
                             p_msg_count        OUT NOCOPY  NUMBER,
                             p_return_status    OUT NOCOPY  VARCHAR2) IS

close_po  g_close_po;
close_rel g_close_rel;
stmt_po                  VARCHAR2(6000);
stmt_rel                 VARCHAR2(4000);
stmt_pa                  VARCHAR2(4000);  --Bug 10371162
po_num_type              VARCHAR2(100);
l_po_num	         po_headers.segment1%TYPE;
l_rel_num                po_releases.release_num%TYPE;
l_doc_id	         po_headers.po_header_id%TYPE;
l_type_code	         po_headers.type_lookup_code%TYPE;
l_doc_subtype            po_document_types.document_subtype%TYPE;
l_release_id             po_releases.po_release_id%TYPE;
l_doc_type               po_document_types.type_name%TYPE;
l_org_id                 NUMBER;
result                   BOOLEAN;
l_return_code            VARCHAR2(100);
l_commit_count           NUMBER;
l_progress               VARCHAR2(3) := '000';
l_log_head               CONSTANT VARCHAR2(1000) := g_log_head||'po_close_documents';

BEGIN

g_document_type    := p_document_type;
g_document_no_from := p_document_no_from;
g_document_no_to   := p_document_no_to;
g_date_from        := p_date_from;
g_date_to          := p_date_to;
g_supplier_id      := p_supplier_id;

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
                          PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_no_to ); -- <BUG 7193855>
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from',p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to',p_date_to);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_id',p_supplier_id);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit_interval',p_commit_interval);

END IF;

SAVEPOINT Close_SP;

l_progress := '001';

BEGIN

SAVEPOINT Close_REC_SP;

	SELECT org_id
	  INTO l_org_id
	  FROM po_system_parameters;

	SELECT hou.name
	  INTO p_org_name
	  FROM hr_all_organization_units hou,
	       hr_all_organization_units_tl hout
	 WHERE hou.organization_id = hout.organization_id
	   AND hout.LANGUAGE = UserEnv('LANG')
	   AND hou.organization_id = l_org_id;

	IF (p_supplier_id IS NOT NULL) then

		SELECT vendor_name
		INTO p_supplier_name
		FROM po_vendors
		WHERE vendor_id = p_supplier_id;

	 END IF;

	 IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_name',p_org_name );
		PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_name',p_supplier_name );

	 END IF;

	 Print_Output(p_org_name,
		      p_document_type,
		      p_document_no_from,
	              p_document_no_to,
	              p_date_from,
	              p_date_to,
	              p_supplier_name,
		      p_msg_data,
                      p_msg_count,
                      p_return_status);

EXCEPTION

WHEN OTHERS THEN
	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO Close_REC_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END;

-- <BUG 7193855 Changed the dynamic sql to return correct results for all the document types>

--Bug 14004642, clean up where conditions
  IF p_document_type IN ('STANDARD','PLANNED') THEN
        stmt_po := 'SELECT poh.segment1 PO_Number,
                       poh.po_header_id,
                       pdt.document_type_code,
                       pdt.document_subtype,
                       pdt.type_name
	          FROM po_headers poh,
	               po_document_types_vl pdt,
        	       po_distributions pod,
                       po_line_locations pll
                 WHERE poh.type_lookup_code = pdt.document_subtype
        	   AND poh.po_header_id = pod.po_header_id
 	           AND poh.po_header_id = pll.po_header_id
          	   AND pll.line_location_id = pod.line_location_id
                   AND Nvl(pll.closed_code,''OPEN'')
                       IN (''CLOSED FOR INVOICE'',
                           ''CLOSED FOR RECEIVING'',''OPEN'')
        	   AND pll.po_release_id IS NULL
        	   AND Nvl(pdt.document_type_code,''PO'') = ''PO''
              	   AND Nvl(poh.authorization_status, ''INCOMPLETE'')
                       IN (''APPROVED'',''REQUIRES REAPPROVAL'')
         	   AND Nvl(poh.closed_code,''OPEN'')
                       NOT IN (''CLOSED'',''FINALLY CLOSED'')
         	   AND Nvl(poh.cancel_flag,''N'') = ''N''';

  ELSIF p_document_type IN ('BLANKET','CONTRACT') THEN
        stmt_po := 'SELECT poh.segment1 PO_Number,
                       poh.po_header_id,
	               pdt.document_type_code,
	               pdt.document_subtype,
	  	       pdt.type_name
		  FROM po_headers poh,
		       po_document_types_vl pdt
	         WHERE poh.type_lookup_code = pdt.document_subtype
		   AND Nvl(pdt.document_type_code,''PA'') = ''PA''
	           AND Nvl(poh.authorization_status, ''INCOMPLETE'')
                       IN (''APPROVED'',''REQUIRES REAPPROVAL'')
		   AND Nvl(poh.closed_code,''OPEN'')
                       NOT IN (''CLOSED'',''FINALLY CLOSED'')
	           AND Nvl(poh.cancel_flag,''N'') = ''N''';
   ELSE
        stmt_po := 'SELECT poh.segment1 PO_Number,
		       poh.po_header_id,
		       pdt.document_type_code,
		       pdt.document_subtype,
		       pdt.type_name
		  FROM po_headers poh,
		       po_document_types_vl pdt,
		       po_distributions pod,
		       po_line_locations pll
		  WHERE poh.type_lookup_code = pdt.document_subtype
		    AND poh.po_header_id = pod.po_header_id
		    AND poh.po_header_id = pll.po_header_id
		    AND pll.line_location_id = pod.line_location_id
		    AND Nvl(pll.closed_code,''OPEN'')
                         IN (''CLOSED FOR INVOICE'',
                             ''CLOSED FOR RECEIVING'',''OPEN'')
		    AND pll.po_release_id IS NULL
		    AND Nvl(pdt.document_type_code,''PO'') = ''PO''
		    AND Nvl(poh.authorization_status, ''INCOMPLETE'')
                        IN (''APPROVED'',''REQUIRES REAPPROVAL'')
	            AND Nvl(poh.closed_code,''OPEN'')
                        NOT IN (''CLOSED'',''FINALLY CLOSED'')
		    AND Nvl(poh.cancel_flag,''N'') = ''N'' ';

       stmt_pa := ' SELECT poh.segment1 PO_Number,
		       poh.po_header_id,
		       pdt.document_type_code,
		       pdt.document_subtype,
		       pdt.type_name
                  FROM po_headers poh,
		       po_document_types_vl pdt
		 WHERE poh.type_lookup_code = pdt.document_subtype
		   AND Nvl(pdt.document_type_code,''PA'') = ''PA''
		   AND Nvl(poh.authorization_status, ''INCOMPLETE'')
                       IN (''APPROVED'',''REQUIRES REAPPROVAL'')
		   AND Nvl(poh.closed_code,''OPEN'')
                       NOT IN (''CLOSED'',''FINALLY CLOSED'')
		   AND Nvl(poh.cancel_flag,''N'') = ''N''';

   END IF;
--End bug 14004642

	IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

		stmt_po := stmt_po || ' AND poh.type_lookup_code = PO_Mass_Close_PO_PVT.get_document_type';
        END IF;

	IF ( po_num_type = 'NUMERIC' ) THEN

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND 1 = 1 ';
			IF(stmt_pa IS NOT NULL ) Then
                        stmt_pa := stmt_pa || ' AND 1 = 1 ';
                        END IF;

                ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_Mass_Close_PO_PVT.get_document_no_from)';
			 IF(stmt_pa IS NOT NULL ) Then
                         stmt_pa := stmt_pa || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_Mass_Close_PO_PVT.get_document_no_from)';
                         END IF;

                ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_Mass_Close_PO_PVT.g_document_no_to)';
			 IF(stmt_pa IS NOT NULL ) Then
                         stmt_pa := stmt_pa || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_Mass_Close_PO_PVT.g_document_no_to)';
                         END IF;

		ELSE

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

						    BETWEEN to_number(PO_Mass_Close_PO_PVT.get_document_no_from) AND to_number(PO_Mass_Close_PO_PVT.get_document_no_to)';
			IF(stmt_pa IS NOT NULL )  Then
                           stmt_pa := stmt_pa || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

						    BETWEEN to_number(PO_Mass_Close_PO_PVT.get_document_no_from) AND to_number(PO_Mass_Close_PO_PVT.get_document_no_to)';
                        END IF;

		END IF;

        ELSE

	        IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND 1 = 1 ';
			IF(stmt_pa IS NOT NULL ) Then
                        stmt_pa := stmt_pa || ' AND 1 = 1 ';
                        END IF;

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND POH.SEGMENT1 >= PO_Mass_Close_PO_PVT.get_document_no_from';
			 IF(stmt_pa IS NOT NULL ) Then
                         stmt_pa := stmt_pa || ' AND POH.SEGMENT1 >= PO_Mass_Close_PO_PVT.get_document_no_from';
                         END IF;

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_po := stmt_po || ' AND POH.SEGMENT1 <= PO_Mass_Close_PO_PVT.get_document_no_to';

                        IF(stmt_pa IS NOT NULL ) Then
                        stmt_pa := stmt_pa || ' AND POH.SEGMENT1 <= PO_Mass_Close_PO_PVT.get_document_no_to';
                        END IF;

		ELSE

			stmt_po := stmt_po || ' AND POH.SEGMENT1 BETWEEN PO_Mass_Close_PO_PVT.get_document_no_from AND PO_Mass_Close_PO_PVT.get_document_no_to';
			IF(stmt_pa IS NOT NULL )  Then
                        stmt_pa := stmt_pa || ' AND POH.SEGMENT1 BETWEEN PO_Mass_Close_PO_PVT.get_document_no_from AND PO_Mass_Close_PO_PVT.get_document_no_to';
                        END IF;


	        END IF;

        END IF; /* po_num_type = 'NUMERIC' */

        /* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND 1 = 1 ';
		IF(stmt_pa IS NOT NULL ) Then
                stmt_pa := stmt_pa || ' AND 1 = 1 ';
                END IF;

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_Mass_Close_PO_PVT.get_date_from)';
		  IF(stmt_pa IS NOT NULL )  Then
                  stmt_pa := stmt_pa || ' AND POH.creation_date >= Trunc(PO_Mass_Close_PO_PVT.get_date_from)';
                  END IF;

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date <= Trunc(PO_Mass_Close_PO_PVT.get_date_to)';
		IF(stmt_pa IS NOT NULL ) Then
                stmt_pa := stmt_pa || ' AND POH.creation_date <= Trunc(PO_Mass_Close_PO_PVT.get_date_to)';
                END IF;


	ELSE
	        stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_Mass_Close_PO_PVT.get_date_from)
		                        AND POH.creation_date < Trunc(PO_Mass_Close_PO_PVT.get_date_to)+1';
                IF(stmt_pa IS NOT NULL ) Then
                stmt_pa := stmt_pa || ' AND POH.creation_date >= Trunc(PO_Mass_Close_PO_PVT.get_date_from)
		                        AND POH.creation_date < Trunc(PO_Mass_Close_PO_PVT.get_date_to)+1';

                END IF;

	END IF;

	IF p_supplier_id IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.vendor_id = PO_Mass_Close_PO_PVT.get_supplier_id';
		 IF(stmt_pa IS NOT NULL )   Then
                stmt_pa := stmt_pa || ' AND POH.vendor_id = PO_Mass_Close_PO_PVT.get_supplier_id';
                END IF;


	END IF;

	 IF(stmt_pa IS NOT NULL ) Then
         stmt_po := '( ' || stmt_po || ' UNION ' || stmt_pa || ' ) '  ;
         END IF;


	stmt_po := stmt_po || ' ORDER BY PO_Number';

IF (p_document_type IS NULL OR p_document_type IN ('STANDARD','BLANKET','PLANNED','CONTRACT','ALL')) THEN  -- <BUG 6988269>

OPEN close_po for stmt_po;

LOOP

FETCH close_po INTO l_po_num,
		    l_doc_id,
		    l_type_code,
		    l_doc_subtype,
		    l_doc_type;

EXIT WHEN close_po%NOTFOUND;

BEGIN

SAVEPOINT Close_PO_SP;

l_progress := '002';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_id',l_doc_id );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_type_code',l_type_code );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_subtype',l_doc_subtype );

	END IF;

l_progress := '003';

   -- Call the Close_PO procedure to perform the action of close on PO's fetched

   result := po_actions.close_po(p_docid         => l_doc_id,
				 p_doctyp 	 => l_type_code,
				 p_docsubtyp 	 => l_doc_subtype,
				 p_lineid 	 => NULL,
				 p_shipid 	 => NULL,
				 p_action 	 => 'CLOSE',
				 p_reason 	 => NULL,
				 p_calling_mode  => 'PO',
				 p_conc_flag 	 => 'N',
				 p_return_code   => l_return_code,
				 p_auto_close    => 'N',
				 p_action_date   => SYSDATE,
				 p_origin_doc_id => NULL);


	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'result',result );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_code',l_return_code );

	END IF;

l_progress := '004';

l_commit_count := l_commit_count + 1;

	IF l_commit_count = p_commit_interval THEN

		COMMIT;
		l_commit_count := 0;

	END IF;

   l_progress := '005';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

	END IF;

	IF (l_return_code = 'STATE_FAILED' ) THEN

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_code',l_return_code );
      END IF;

    ELSE
		fnd_file.put_line(fnd_file.output, rpad(l_po_num,26)  ||  l_doc_type);
	END IF;

EXCEPTION

WHEN OTHERS THEN

IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO Close_PO_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END;

 END LOOP;

 CLOSE close_po;

 END IF; -- <End of p_document_type>

 l_progress := '006';

  --Bug 13877857, move pod, pll to subquery to suppress the duplicate
  --releases in output.
  --Bug 14004642, clean up conditions
  stmt_rel := 'SELECT poh.segment1,
                      por.po_release_id,
                      por.release_num,
                      pdt.document_type_code,
                      pdt.document_subtype,
                      pdt.type_name
                 FROM po_releases por,
                      po_headers poh,
                      po_document_types_vl pdt
                WHERE por.po_header_id = poh.po_header_id
                  AND pdt.document_type_code = ''RELEASE''
                  AND pdt.document_subtype = por.release_type
                  AND Nvl(por.authorization_status,''INCOMPLETE'')
                      IN (''APPROVED'',''REQUIRES REAPPROVAL'')
                  AND Nvl(por.closed_code,''OPEN'')
                      NOT IN (''CLOSED'',''FINALLY CLOSED'')
                  AND Nvl(por.cancel_flag,''N'') = ''N''
                  AND EXISTS
                      (SELECT 1
                         FROM po_distributions_all pod,
                              po_line_locations_all pll
                        WHERE por.po_header_id = pod.po_header_id
                          AND por.po_header_id = pll.po_header_id
                          AND pll.line_location_id = pod.line_location_id
                          AND pod.po_release_id IS NOT NULL
                          AND Nvl(pll.closed_code,''OPEN'')
                              IN (''CLOSED FOR INVOICE'',
                                  ''CLOSED FOR RECEIVING'',''OPEN'')
                      ) ';  --End bug 14004642
  --end bug 13877857

		IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

			stmt_rel := stmt_rel || 'AND ((PO_Mass_Close_PO_PVT.get_document_type = ''PLANNED'' and por.release_type = ''SCHEDULED'')

						 OR (por.release_type = Nvl(PO_Mass_Close_PO_PVT.get_document_type,por.release_type)))';

		END IF;

		IF ( po_num_type = 'NUMERIC' ) THEN

			IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND 1 = 1 ';

		        ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) >= to_number(PO_Mass_Close_PO_PVT.get_document_no_from)';

			ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

				stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) <= to_number(PO_Mass_Close_PO_PVT.get_document_no_to)';

			ELSE

				stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL )

							      BETWEEN to_number(PO_Mass_Close_PO_PVT.get_document_no_from) AND to_number(PO_Mass_Close_PO_PVT.get_document_no_to)';

			END IF;

		ELSE

			IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND 1 = 1 ';

			ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND POH.SEGMENT1 >= PO_Mass_Close_PO_PVT.get_document_no_from';

			ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

				stmt_rel := stmt_rel || ' AND POH.SEGMENT1 <= PO_Mass_Close_PO_PVT.get_document_no_to';

			ELSE

				stmt_rel := stmt_rel || ' AND POH.SEGMENT1 BETWEEN PO_Mass_Close_PO_PVT.get_document_no_from AND PO_Mass_Close_PO_PVT.get_document_no_to'; -- <BUG 7193855>

			END IF;

		END IF; /* po_num_type = 'NUMERIC' */

		/* Bug 6899092 Added Trunc condition in validating the date ranges */

		IF p_date_from IS NULL AND p_date_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND 1 = 1 ';

		ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_Mass_Close_PO_PVT.get_date_from)';

		ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

			stmt_rel := stmt_rel || ' AND POR.creation_date <= Trunc(PO_Mass_Close_PO_PVT.get_date_to)';

		ELSE

			stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_Mass_Close_PO_PVT.get_date_from)
			                          AND POR.creation_date < Trunc(PO_Mass_Close_PO_PVT.get_date_to)+1';

		END IF;

		IF p_supplier_id IS NOT NULL THEN

			stmt_rel := stmt_rel || ' AND POH.vendor_id = PO_Mass_Close_PO_PVT.get_supplier_id';

		END IF;

		stmt_rel := stmt_rel || ' ORDER BY poh.segment1,por.release_num';


		IF (p_document_type IS NULL OR p_document_type IN ('BLANKET','PLANNED', 'ALL')) THEN  -- <BUG 6988269 Added 'ALL' condition>


		OPEN close_rel for stmt_rel;
		LOOP

		FETCH close_rel INTO l_po_num,
				     l_release_id,
				     l_rel_num,
				     l_type_code,
				     l_doc_subtype,
				     l_doc_type;

		EXIT WHEN close_rel%NOTFOUND;

		BEGIN

		SAVEPOINT Close_REL_SP;

		l_progress := '007';

		IF g_debug_stmt THEN

			PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
			PO_DEBUG.debug_var(l_log_head,l_progress,'l_release_id',l_release_id );
			PO_DEBUG.debug_var(l_log_head,l_progress,'l_type_code',l_type_code );

		END IF;

		l_progress := '008';

		-- Call the Close_PO procedure to perform the action of close on Releases fetched

		result := po_actions.close_po(p_docid         => l_release_id,
		                              p_doctyp 	      => l_type_code,
				              p_docsubtyp     => l_doc_subtype,
				              p_lineid 	      => NULL,
					      p_shipid 	      => NULL,
	                                      p_action 	      => 'CLOSE',
                                              p_reason 	      => NULL,
                    			      p_calling_mode  => 'PO',
		          	              p_conc_flag     => 'N',
			         	      p_return_code   => l_return_code,
				              p_auto_close    => 'N',
				              p_action_date   => SYSDATE,
				              p_origin_doc_id => NULL);

		IF g_debug_stmt THEN

			PO_DEBUG.debug_var(l_log_head,l_progress,'result',result );
			PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_code',l_return_code );

		END IF;


		l_progress := '009';

		l_commit_count := l_commit_count + 1;

			IF l_commit_count = p_commit_interval THEN

				COMMIT;
				l_commit_count := 0;

			END IF;

			IF g_debug_stmt THEN

				PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

			END IF;

		EXCEPTION

		WHEN OTHERS THEN

			IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

			END IF;

		ROLLBACK TO Close_REL_SP;

		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

				FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

			END IF;

		FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

		END;

  fnd_file.put_line(fnd_file.output, rpad(l_po_num || '-' || l_rel_num,26) || l_doc_type);



 END LOOP;

 CLOSE close_rel;

 END IF; -- <End of p_document_type>

EXCEPTION

WHEN OTHERS THEN

     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO Close_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END po_close_documents;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Print_Output
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Prints the header and body of the output file showing the documents and
--		document types which are closed.

-- Parameters :

-- IN         : p_org_name             Operating unit name.
--		p_document_type        Type of the document(STANDARD,BLANKET.CONTRACT,PLANNED).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_supplier_name        Supplier name.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Print_Output(p_org_name         IN VARCHAR2,
                       p_document_type    IN VARCHAR2,
                       p_document_no_from IN VARCHAR2,
                       p_document_no_to   IN VARCHAR2,
                       p_date_from        IN DATE,
                       p_date_to          IN DATE,
                       p_supplier_name    IN VARCHAR2,
		       p_msg_data         OUT NOCOPY  VARCHAR2,
                       p_msg_count        OUT NOCOPY  NUMBER,
                       p_return_status    OUT NOCOPY  VARCHAR2) IS

l_msg1             VARCHAR2(240);
l_msg2             VARCHAR2(240);
l_msg3             VARCHAR2(240);
l_msg4             VARCHAR2(240);
l_msg5             VARCHAR2(240);
l_msg6             VARCHAR2(240);
l_msg7             VARCHAR2(240);
l_msg8             VARCHAR2(240);
l_msg9             VARCHAR2(240);
l_msg10            VARCHAR2(240);
l_msg11            VARCHAR2(240);
l_msg12            VARCHAR2(240);
l_progress         VARCHAR2(3);
l_log_head         CONSTANT VARCHAR2(1000) := g_log_head||'Print_Output';

BEGIN

fnd_message.set_name('PO','PO_MUB_MSG_CLOSE_HEADER1');
     l_msg1 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DATE');
     l_msg2 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_OU');
     l_msg3 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_SUB_TYPE');
     l_msg4 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM_FROM');
     l_msg5 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM_TO');
     l_msg6 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DATE_FROM');
     l_msg7 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DATE_TO');
     l_msg8 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_SUPPLIER');
     l_msg9 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_CLOSE_HEADER2');
     l_msg10 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM');
     l_msg11 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_TYPE');
     l_msg12 := fnd_message.get;

     SAVEPOINT Print;

     l_progress  := '001';

     IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_name',p_supplier_name );

     END IF;

     fnd_file.put_line(fnd_file.output, l_msg1);
     fnd_file.put_line(fnd_file.output, '                         ');
     fnd_file.put_line(fnd_file.output, rpad(l_msg2,21)  || ' : ' || sysdate);
     fnd_file.put_line(fnd_file.output, rpad(l_msg3,21)  || ' : ' || p_org_name);
     l_progress  := '002';
     fnd_file.put_line(fnd_file.output, rpad(l_msg4,21)  || ' : ' || p_document_type);
     fnd_file.put_line(fnd_file.output, rpad(l_msg5,21)  || ' : ' || p_document_no_from);
     fnd_file.put_line(fnd_file.output, rpad(l_msg6,21)  || ' : ' || p_document_no_to);
     fnd_file.put_line(fnd_file.output, rpad(l_msg7,21)  || ' : ' || p_date_from);
     l_progress  := '003';
     fnd_file.put_line(fnd_file.output, rpad(l_msg8,21)  || ' : ' || p_date_to);
     fnd_file.put_line(fnd_file.output, rpad(l_msg9,21)  || ' : ' || p_supplier_name);
     fnd_file.put_line(fnd_file.output, '                                         ');
     fnd_file.put_line(fnd_file.output, l_msg10);
     fnd_file.put_line(fnd_file.output, '                                                      ');
     l_progress  := '004';
     fnd_file.put_line(fnd_file.output,  rpad(l_msg11,26) || l_msg12);
     fnd_file.put_line(fnd_file.output,  rpad('-',60,'-'));


EXCEPTION

WHEN OTHERS THEN

     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

END IF;

ROLLBACK TO Print;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Print_Output;

--------------------------------------------------------------------------------------------------

-- Functions declared to return the value of the parameters passed in this API.

--------------------------------------------------------------------------------------------------

FUNCTION get_document_type RETURN VARCHAR2
IS
BEGIN
	RETURN g_document_type;
END;

FUNCTION get_document_no_from RETURN VARCHAR2
IS
BEGIN
	RETURN g_document_no_from;
END;

FUNCTION get_document_no_to RETURN VARCHAR2
IS
BEGIN
	RETURN g_document_no_to;
END;

FUNCTION get_date_from RETURN DATE
IS
BEGIN
	RETURN g_date_from;
END;

FUNCTION get_date_to RETURN DATE
IS
BEGIN
	RETURN g_date_to;
END;

FUNCTION get_supplier_id RETURN NUMBER
IS
BEGIN
	RETURN g_supplier_id;
END;


END PO_Mass_Close_PO_PVT;

/
