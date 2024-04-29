--------------------------------------------------------
--  DDL for Package Body GR_XML_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_XML_REPORTS" AS
/* $Header: GRXREPB.pls 120.0 2005/10/03 07:36:26 ragsriva noship $ */
   PROCEDURE dispatch_history_report (
      errbuf                     OUT NOCOPY      VARCHAR2
    , retcode                    OUT NOCOPY      VARCHAR2
    , p_organization_id          IN              NUMBER
    , p_from_item                IN              VARCHAR2
    , p_to_item                  IN              VARCHAR2
    , p_from_recipient           IN              VARCHAR2
    , p_to_recipient             IN              VARCHAR2
    , p_from_document_category   IN              VARCHAR2
    , p_to_document_category     IN              VARCHAR2
    , p_from_date_sent           IN              VARCHAR2
    , p_to_date_sent             IN              VARCHAR2
    , p_cas_number               IN              VARCHAR2
    , p_ingredient_item_id       IN              NUMBER
    , p_order_by                 IN              VARCHAR2) IS

      p_from_date    DATE;
      p_to_date      DATE;
      l_xml_query    VARCHAR2 (32000);
      l_queryctx     DBMS_XMLGEN.ctxhandle;
      l_xml_result   CLOB;
   BEGIN
      p_from_date :=  fnd_date.canonical_to_date(p_from_date_sent);
      p_to_date := fnd_date.canonical_to_date(p_to_date_sent);

      l_xml_query :=
            ' SELECT organization_code '
         || '     , SYSDATE report_date '
         || '     , CURSOR (SELECT grdh.* '
         || '		    , fdc.user_name document_category_user_name '
         || '		 FROM gr_dispatch_history_v grdh '
         || '		    , fnd_document_categories_vl fdc '
         || '		WHERE grdh.organization_id = mp.organization_id '
         || '		  AND grdh.document_category = fdc.NAME(+) ';



      IF     p_from_item IS NOT NULL
         AND p_to_item IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.item >= ''' || p_from_item || '''';
         l_xml_query := l_xml_query || ' AND grdh.item <= ''' || p_to_item || '''';
      ELSIF p_from_item IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.item >= ''' || p_from_item || '''';
      ELSIF p_to_item IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.item <= ''' || p_to_item || '''';
      END IF;

      IF     p_from_recipient IS NOT NULL
         AND p_to_recipient IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.recipient_number >= ''' || p_from_recipient || '''';
         l_xml_query := l_xml_query || ' AND grdh.recipient_number <= ''' || p_to_recipient || '''';
      ELSIF p_from_recipient IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.recipient_number >= ''' || p_from_recipient || '''';
      ELSIF p_to_recipient IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.recipient_number <= ''' || p_to_recipient || '''';
      END IF;

      IF     p_from_document_category IS NOT NULL
         AND p_to_document_category IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.document_category >= ''' || p_from_document_category || '''';
         l_xml_query := l_xml_query || ' AND grdh.document_category <= ''' || p_to_document_category || '''';
      ELSIF p_from_document_category IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.document_category >= ''' || p_from_document_category || '''';
      ELSIF p_to_document_category IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.document_category <= ''' || p_to_document_category || '''';
      END IF;

      IF     p_from_date_sent IS NOT NULL
         AND p_to_date_sent IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.date_sent >= ''' || p_from_date || '''';
         l_xml_query := l_xml_query || ' AND grdh.date_sent <= ''' || p_to_date || '''';
      ELSIF p_from_date_sent IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.date_sent >= ''' || p_from_date || '''';
      ELSIF p_to_date_sent IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.date_sent <= ''' || p_to_date || '''';
      END IF;

      IF p_cas_number IS NOT NULL THEN
         l_xml_query := l_xml_query || ' AND grdh.cas_number = ''' || p_cas_number || '''';
      END IF;

      IF p_ingredient_item_id IS NOT NULL THEN
         l_xml_query :=
               l_xml_query
            || ' AND grdh.inventory_item_id IN (SELECT product_item_id FROM gr_ingredient_concentrations '
            || '                                 WHERE organization_id = ' || p_organization_id
            || '                                   AND ingredient_item_id = ' || p_ingredient_item_id
            || ' ) ';
      END IF;

      IF p_order_by = '1' THEN
         l_xml_query := l_xml_query || ' ORDER BY grdh.date_sent ';
      ELSIF p_order_by = '2' THEN
         l_xml_query := l_xml_query || ' ORDER BY grdh.recipient ';
      ELSE
         l_xml_query := l_xml_query || ' ORDER BY grdh.item ';
      END IF;

      l_xml_query :=
            l_xml_query
         || ' ) DISPATCH_INFO '
         || ' FROM mtl_parameters mp '
         || ' WHERE organization_id = ' || p_organization_id;

      fnd_file.put_line (fnd_file.LOG, l_xml_query);

      l_queryctx := DBMS_XMLGEN.newcontext (l_xml_query);
      l_xml_result := DBMS_XMLGEN.getxml (l_queryctx);
      xml_transfer (p_xml_clob => l_xml_result);
      DBMS_XMLGEN.closecontext (l_queryctx);

   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, 'Exception in procedure DISPATCH_HISTORY_REPORT ' || SQLCODE || ' ' || SQLERRM);
   END dispatch_history_report;

   PROCEDURE xml_transfer (
      p_xml_clob   IN   CLOB) IS
      l_file          CLOB;
      file_varchar2   VARCHAR2 (4000);
      l_len           NUMBER;
      l_limit         NUMBER;
   BEGIN
      l_file := p_xml_clob;
      l_limit := 1;
      l_len := DBMS_LOB.getlength (l_file);

      LOOP
         IF l_len > l_limit THEN
            file_varchar2 := DBMS_LOB.SUBSTR (l_file, 4000, l_limit);
            fnd_file.put (fnd_file.output, file_varchar2);
            file_varchar2 := NULL;
            l_limit := l_limit + 4000;
         ELSE
            file_varchar2 := DBMS_LOB.SUBSTR (l_file, 4000, l_limit);
            fnd_file.put (fnd_file.output, file_varchar2);
            file_varchar2 := NULL;
            EXIT;
         END IF;
      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, 'Exception in procedure XML_TRANSFER ' || SQLCODE || ' ' || SQLERRM);
   END xml_transfer;

END GR_XML_REPORTS;

/
