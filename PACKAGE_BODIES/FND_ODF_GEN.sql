--------------------------------------------------------
--  DDL for Package Body FND_ODF_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ODF_GEN" AS
/* $Header: fndpodfb.pls 120.6 2006/02/15 02:02 vkhatri noship $ */
PROCEDURE odfgen_xml (p_objType         IN VARCHAR2,
                      p_objName         IN VARCHAR2,
                      p_schemaName      IN VARCHAR2,
                      p_concatVar       IN VARCHAR2,
                      p_appshortName    IN VARCHAR2,
                      p_objMode         IN VARCHAR2,
                      p_includeTrigger  IN VARCHAR2,
                      p_includeSequence IN VARCHAR2,
                      p_includePolicy   IN VARCHAR2,
                      p_objInfo        OUT NOCOPY VARCHAR2,
                      p_policyCtr       OUT NOCOPY NUMBER,
                      p_triggerCtr     OUT NOCOPY NUMBER,
                      p_sequenceCtr    OUT NOCOPY NUMBER,
                      p_sysName        OUT NOCOPY NUMBER,
                      p_retXML         OUT NOCOPY CLOB)

IS
  l_objOpenHandle                NUMBER;
  l_objXMLOpenHandle             NUMBER;
  l_indexOpenHandle              NUMBER;
  l_indexOpenHandle1             NUMBER;
  l_triggerOpenHandle            NUMBER;
  l_commentOpenHandle            NUMBER;
  l_commentCtr                   NUMBER;
  l_ctr                          NUMBER;
  l_finalXML                     CLOB;
  l_tmpXML                       CLOB;
  l_indexNameXML                 sys.XMLtype;
  l_objXMLs                      sys.XMLType;
  l_eobjXMLs                     sys.XMLType;
  l_indexXMLs                    sys.XMLType;
  l_triggerXMLs                  sys.XMLType;
  l_sysNameXML                   sys.XMLType;
  l_commentXMLs                  sys.XMLType;
  l_policyXMLs                   sys.XMLType; --added by adusange
  parsedItems                    sys.ku$_parsed_items;
  l_tableName                    VARCHAR2(30);
  l_buf                          VARCHAR2(32000);
  l_tmpBuf                       VARCHAR2(30);
  l_indexName                    VARCHAR2(50);
  l_triggerName                  VARCHAR2(50);
  l_mlogName                     VARCHAR2(30);
  l_objName                      VARCHAR2(30);
  l_consName                     VARCHAR2(32000);
  l_subqry                       VARCHAR2(2000);
  l_seqNameExp                   VARCHAR2(200);
  l_depInfo                      VARCHAR2(2000);
  p_typ                          VARCHAR2(30);
  l_seqListing                   VARCHAR2(100);
  l_policyListing                VARCHAR2(100);
  l_indexCtr                     NUMBER;
  l_sqlCond                      VARCHAR2(2000);

  TYPE NameTab IS TABLE OF sys.obj$.name%TYPE;
  l_triggNames NameTab;
  l_triggList  VARCHAR2(2000);

  e_dbms_metadata_01             EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_dbms_metadata_01, -31603); -- see bug #3108046
  e_dbms_metadata_02             EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_dbms_metadata_02, -31608); -- regular exception

 begin
    l_indexCtr := 0;
    p_triggerCtr := 0;
    p_sysName := 0;
    l_objOpenHandle := sys.ad_dbms_metadata.open(p_objType);
    l_ctr := 0;

/*    l_ctr := NVL(p_includeTrigger, 1); */

    if ( p_includeTrigger is NULL ) then
        l_ctr := 1;
    end if;

    l_depInfo := 'Primary Object''s Application Short Name : ' || '
'|| '    ' || p_appshortName || '
';
    l_depInfo := l_depInfo || 'If this application short name is incorrect ' ||
                 'please regenerate the xdf file by providing the parameter '||
                 'owner_app_shortname with the correct value.
';

    l_depInfo :=  l_depInfo || 'Primary Object Schema Name : ' || '
'|| '    ' || p_schemaName || '
';

    if ( p_objMode = 'policy' ) then
       l_depInfo :=  l_depInfo || 'Primary Object Name : ' || '
'|| '    ' || p_includePolicy || '
';
    else
       l_depInfo :=  l_depInfo || 'Primary Object Name : ' || '
'|| '    ' || p_objName || '
';
    end if;

    l_depInfo := l_depInfo || 'Primary Object Type : ' || '
'|| '    ' || p_objType || '
';

    if ( p_objMode = 'mviewlog' or p_objMode = 'policy' ) then
         sys.ad_dbms_metadata.set_filter(l_objOpenHandle,'BASE_OBJECT_SCHEMA',p_schemaName);
         sys.ad_dbms_metadata.set_filter(l_objOpenHandle,'BASE_OBJECT_NAME',p_objName);
    elsif (p_objMode = 'sequence' or p_objMode= 'trigger' or p_objMode = 'type') then
         l_seqNameExp := 'LIKE ''' || p_objName || '''';
         sys.ad_dbms_metadata.set_filter(l_objOpenHandle, 'NAME_EXPR',l_seqNameExp);
         sys.ad_dbms_metadata.set_filter(l_objOpenHandle, 'SCHEMA', p_schemaName);
    elsif (p_objMode = 'context' ) then
         sys.ad_dbms_metadata.set_filter(l_objOpenHandle, 'NAME', p_objName);
    else /* mview, table, index, aq_table, policies etc. */
         sys.ad_dbms_metadata.set_filter(l_objOpenHandle, 'NAME', p_objName);
         sys.ad_dbms_metadata.set_filter(l_objOpenHandle, 'SCHEMA', p_schemaName);
    end if;

    l_finalXML := '<ROWSET>
';
    l_tmpXML := '<APPL_SHORT_NAME>' || p_appshortName || '</APPL_SHORT_NAME>
';
    dbms_lob.append(l_finalXML,l_tmpXML);

    if (p_concatVar IS NOT NULL) then
        l_tmpXML := '<TYPE_APPL_SHORT_NAME>' || p_concatVar || '</TYPE_APPL_SHORT_NAME>
';
    else
        l_tmpXML := '<TYPE_APPL_SHORT_NAME>0</TYPE_APPL_SHORT_NAME>
';
    end if;
    dbms_lob.append(l_finalXML,l_tmpXML);

    /* vkhatri bug 4929568 */
    if ( p_objMode = 'type' ) then
            l_tmpXML := '<APPS_TYPE>
';
            dbms_lob.append(l_finalXML,l_tmpXML);
            get_type_attr(p_objName,p_schemaName,p_appshortName,l_tmpXML);
            dbms_lob.append(l_finalXML,l_tmpXML);
	    get_type_method(p_objName,p_schemaName,p_appshortName,l_tmpXML);
            dbms_lob.append(l_finalXML,l_tmpXML);
            l_tmpXML := '</APPS_TYPE>
';
            dbms_lob.append(l_finalXML,l_tmpXML);
    end if;

    /* Extracting aol metadata for table */
    if ( p_objMode = 'table' ) then
          /* is_temp_iot( p_objName, p_schemaName, p_typ);  // added support for aol metadata for IOT and GTT
           if(p_typ = 'N') then */
            l_tmpXML := '<APPS_AOL_METADATA>';
            dbms_lob.append(l_finalXML,l_tmpXML);
            get_fnd_table_metadata(p_objName,p_schemaName,p_appshortName,l_tmpXML);
            dbms_lob.append(l_finalXML,l_tmpXML);
            l_tmpXML := '</APPS_AOL_METADATA>
';
            dbms_lob.append(l_finalXML,l_tmpXML);
           --end if;
    end if;


    /* Extracting aol metadata for views */
    if ( p_objMode = 'view' ) then
         get_fnd_view_metadata(p_objName,p_schemaName,p_appshortName,l_tmpXML);
         dbms_lob.append(l_finalXML,l_tmpXML);
    end if;

  /*  Extracting AOL metadata for mview */

 if ( p_objMode = 'mview' ) then
            l_tmpXML := '<APPS_AOL_METADATA>';
            dbms_lob.append(l_finalXML,l_tmpXML);
              get_fnd_mview_metadata(p_objName,p_schemaName,p_appshortName,l_tmpXML);
            dbms_lob.append(l_finalXML,l_tmpXML);
            l_tmpXML := '</APPS_AOL_METADATA>';
            dbms_lob.append(l_finalXML,l_tmpXML);
   end if;



    if ( p_objMode = 'policy' ) then
         get_xml_policy(p_objName,p_schemaName,p_includePolicy,p_policyCtr, l_policyListing,l_tmpXML);
         if ( l_tmpXML is not null ) then
              dbms_lob.append(l_finalXML,l_tmpXML);
         end if;

    else

     LOOP
       /* Main loop for master objects */
       l_objXMLs  :=  sys.ad_dbms_metadata.fetch_xml(l_objOpenHandle);
       EXIT WHEN l_objXMLs IS NULL;

       l_eobjXMLs := XMLType.extract(l_objXMLs,'ROWSET/ROW');

      if ( p_objMode = 'table' ) then
         /* check if the constraints are system generated */
         l_sysNameXML := XMLType.extract(l_objXMLs,'ROWSET/ROW/TABLE_T/CON1_LIST/CON1_LIST_ITEM/NAME');
         if (NOT l_sysNameXML IS NULL ) then
            l_consName := l_sysNameXML.getStringVal();

            if (instr(l_consName,'>SYS_') <> 0)  then
                p_sysName := 1;
            end if;
         end if;

         if ( p_sysName <> 1 ) then
            l_sysNameXML := XMLType.extract(l_objXMLs,'ROWSET/ROW/TABLE_T/CON2_LIST/CON2_LIST_ITEM/NAME');
            if (NOT l_sysNameXML IS NULL ) then
                l_consName := l_sysNameXML.getStringVal();
                if (instr(l_consName,'>SYS_') <> 0)  then
                    p_sysName := 1;
                end if;
            end if;
         end if;

      end if;


     l_tmpXML   := l_eobjXMLs.getClobVal();
     dbms_lob.append(l_finalXML,l_tmpXML);

     if( p_objMode <> 'index' and
         p_objMode <> 'policy' and
         p_objMode <> 'context' and
         p_objMode <> 'sequence' and
         p_objMode <> 'type' )  then
     l_depInfo :=  l_depInfo || 'Dependent Object Information : '   ||  '
';
     end if;

	 /* Mladena - for accurate MV Log name */

	 if ( p_objMode in ('mview', 'mviewlog') ) then

	  	 begin
	  	   select log_table
		   into   l_mlogName
		   from   dba_mview_logs
		   where  master = p_objName
		   and    log_owner = p_schemaName;
	     exception
		   when no_data_found then
 		     l_mlogName := null;
		   WHEN OTHERS
             THEN RAISE_APPLICATION_ERROR(
                   -20001, 'Internal data error', TRUE);
		 end;

	 end if;

	 /*--- End Mladena */

/* ================================================================ */
     if ( p_objMode = 'mview' ) then
          /* reusing the l_indexOpenHandle to get materialized view log */
          l_indexOpenHandle := sys.ad_dbms_metadata.open('MATERIALIZED_VIEW_LOG');
          sys.ad_dbms_metadata.set_filter(l_indexOpenHandle,'BASE_OBJECT_SCHEMA',p_schemaName);
          sys.ad_dbms_metadata.set_filter(l_indexOpenHandle,'BASE_OBJECT_NAME',p_objName);
          LOOP
-- Amit Code.
            BEGIN
              l_indexXMLs := sys.ad_dbms_metadata.fetch_xml(l_indexOpenHandle);
              EXIT WHEN l_indexXMLs IS NULL;
            EXCEPTION
            WHEN e_dbms_metadata_01 OR e_dbms_metadata_02
            THEN EXIT;
            WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(
                   -20001, 'Internal sys.ad_dbms_metadata.fetch_xml error', TRUE);
            END;

 l_depInfo := l_depInfo  || 'Materialized view log : '  || '
' ||  '    ' ||   l_mlogName
              ||  '
';

               l_eobjXMLs := XMLType.extract(l_indexXMLs,'ROWSET/ROW');
               l_tmpXML  := l_eobjXMLs.getClobVal();
               dbms_lob.append(l_finalXML,l_tmpXML);

               /* get the indexes on mviewlogs */
               l_indexOpenHandle1 := sys.ad_dbms_metadata.open('INDEX');
               l_depInfo := l_depInfo  || 'Indexes on Materialized view log of ' || p_objMode
                                       ||  ' : ' || '
';
               sys.ad_dbms_metadata.set_filter(l_indexOpenHandle1,'BASE_OBJECT_SCHEMA',p_schemaName);
               sys.ad_dbms_metadata.set_filter(l_indexOpenHandle1,'BASE_OBJECT_NAME', l_mlogName);
               sys.ad_dbms_metadata.set_filter(l_indexOpenHandle1,'SYSTEM_GENERATED',false);
  --Amit Code.

               LOOP
                 BEGIN
                   l_indexXMLs := sys.ad_dbms_metadata.fetch_xml(l_indexOpenHandle1);
                   EXIT WHEN l_indexXMLs IS NULL;
                 EXCEPTION
                 WHEN e_dbms_metadata_01 OR e_dbms_metadata_02
                 THEN l_indexCtr := 0; EXIT;
                 WHEN OTHERS
                 THEN RAISE_APPLICATION_ERROR(
                         -20001, 'Internal sys.ad_dbms_metadata.fetch_xml error', TRUE);
                 END;

                   l_eobjXMLs := XMLType.extract(l_indexXMLs,'ROWSET/ROW');

                   SELECT extractValue(l_indexXMLs,'ROWSET/ROW/INDEX_T/SCHEMA_OBJ/NAME')
                   INTO   l_indexName
                   FROM DUAL;
                   l_tmpXML  := l_eobjXMLs.getClobVal();
                   if (instr(l_indexName,'I_SNAP$')= 0)  then
                       l_indexCtr := l_indexCtr + 1;
                       l_depInfo :=  l_depInfo || '    ' ||  l_indexName  ||  '
';
                       dbms_lob.append(l_finalXML,l_tmpXML);
                   end if;
               END LOOP; -- end of index loop.

			   if ( l_indexCtr = 0 ) then
                    l_depInfo := l_depInfo  || '    None '  ||  '
';
			   end if;

               sys.ad_dbms_metadata.close(l_indexOpenHandle1);

          END LOOP;  --end of mview loop

          sys.ad_dbms_metadata.close(l_indexOpenHandle);
     end if;  -- end of if(mview) stmt.
/* ================================================================ */
/* rsekaran
   - 4486719
   - Commented the check for qtable so that index objects are captured for Qtable
*/
     if ( p_objMode <> 'sequence' and
                p_objMode <> 'trigger' and
--                p_objmode <> 'qtable'  and
                p_objmode <> 'queue'  and
                p_objmode <> 'context'  and
--                p_objmode <> 'view'  and
                p_objmode <> 'index'  and
                p_objMode <> 'type' ) then
       /* Get the index information */
       l_indexOpenHandle := sys.ad_dbms_metadata.open('INDEX');
       l_depInfo := l_depInfo  || 'Indexes on ' || p_objName
                               || ' : '  || '
';
       sys.ad_dbms_metadata.set_filter(l_indexOpenHandle,'BASE_OBJECT_SCHEMA',p_schemaName);

       if ( p_objMode <> 'mviewlog' ) then
          sys.ad_dbms_metadata.set_filter(l_indexOpenHandle,'BASE_OBJECT_NAME',p_objName);
          /* rsekaran - 4486719
             Added additional checks for qtables to filter out index names starting with 'AQ$_'
          */
          if ( p_objMode = 'qtable' ) then
            l_sqlCond := ' not in ( select index_name from dba_indexes where (index_type=''DOMAIN'' or index_name like ''AQ$_%'') and table_name='''||p_objName||''' and owner='''||p_schemaName||''' ) ';
          else
            l_sqlCond := ' not in ( select index_name from dba_indexes where index_type=''DOMAIN'' and table_name='''||p_objName||''' and owner='''||p_schemaName||''' ) ';
          end if;
       else
          sys.ad_dbms_metadata.set_filter(l_indexOpenHandle,'BASE_OBJECT_NAME', l_mlogName);
          l_sqlCond := ' not in ( select index_name from dba_indexes where index_type=''DOMAIN'' and table_name='''||l_mlogName||''' and owner='''||p_schemaName||''' ) ';
       end if;

       sys.ad_dbms_metadata.set_filter(l_indexOpenHandle,'SYSTEM_GENERATED',false);

       /* Mladena - no domain indexes until bug#3225530 backport is available */

       sys.ad_dbms_metadata.set_filter(l_indexOpenHandle,'NAME_EXPR', l_sqlCond);

       /* end Mladena */

       LOOP
-- Amit Code
          begin
          l_indexXMLs := sys.ad_dbms_metadata.fetch_xml(l_indexOpenHandle);
          EXIT WHEN l_indexXMLs IS NULL;
          EXCEPTION
          when others then
           l_indexCtr := 0;
          EXIT;
          end;

          l_eobjXMLs := XMLType.extract(l_indexXMLs,'ROWSET/ROW');
          SELECT extractValue(l_indexXMLs,'ROWSET/ROW/INDEX_T/SCHEMA_OBJ/NAME')
          INTO   l_indexName
          FROM DUAL;


 --         l_indexNameXML := XMLType.extract(l_indexXMLs,'ROWSET/ROW/INDEX_T/SCHEMA_OBJ/NAME');
 --         l_indexName := l_indexNameXML.getStringVal();
          l_tmpXML  := l_eobjXMLs.getClobVal();
          if (instr(l_indexName,'I_SNAP$')= 0)  then
              l_depInfo := l_depInfo || '    ' ||  l_indexName  ||  '
';
              l_indexCtr := l_indexCtr + 1;
              dbms_lob.append(l_finalXML,l_tmpXML);
          end if;
       END LOOP;

	   if ( l_indexCtr = 0 ) then
	        l_depInfo := l_depInfo  || '    None ' || '
';
	   end if;

       sys.ad_dbms_metadata.close(l_indexOpenHandle);


       /* Get the trigger information - Mladena */

	   if ( p_objMode <> 'mviewlog' ) then
	        l_objName := p_objName;
	   else
                l_objName := l_mlogName;
           end if;

	   Begin

	     select ot.name BULK COLLECT INTO l_triggNames
		 from   sys.obj$ ot, sys.obj$ bo, sys.trigger$ t
		 where  t.BASEOBJECT = bo.OBJ#
		 and    bo.NAME = l_objName
		 and    ot.OBJ# = t.OBJ#;

	   exception
		 when no_data_found then
			  l_triggList := 'Empty';
	   End;

	   if l_triggNames.COUNT > 0 then

	   	  l_triggList := ''''||l_triggNames(l_triggNames.FIRST)||'''';

	      for i in l_triggNames.FIRST+1 .. l_triggNames.LAST loop

	   	   	l_triggList := l_triggList||','''||l_triggNames(i)||'''';

	      end loop;

              l_subqry := 'IN ('|| l_triggList ||')';

	      l_triggerOpenHandle := sys.ad_dbms_metadata.open('TRIGGER');
  	      l_depInfo := l_depInfo || 'Triggers on ' || l_objName || ' : ' || '';

              sys.ad_dbms_metadata.set_filter(l_triggerOpenHandle,'NAME_EXPR',l_subqry);
	      sys.ad_dbms_metadata.set_filter(l_triggerOpenHandle,'SYSTEM_GENERATED',false);
          sys.ad_dbms_metadata.set_parse_item(l_triggerOpenHandle,'NAME');

          LOOP
         -- Amit Code.
            begin
            l_triggerXMLs := sys.ad_dbms_metadata.fetch_xml(l_triggerOpenHandle);
            EXIT WHEN l_triggerXMLs IS NULL;
            EXCEPTION
            when others then
            p_triggerCtr := 0;
            EXIT;
            end;
            l_eobjXMLs := XMLType.extract(l_triggerXMLs,'ROWSET/ROW');

            SELECT extractValue(l_triggerXMLs,'ROWSET/ROW/TRIGGER_T/SCHEMA_OBJ/NAME')
            INTO   l_triggerName
            FROM DUAL;

            if ((l_ctr = 1) or (instr(p_includeTrigger,l_triggerName) <> 0))  then
                l_tmpXML   := l_eobjXMLs.getClobVal();
                dbms_lob.append(l_finalXML,l_tmpXML);
              l_depInfo := l_depInfo  || '    ' ||  l_triggerName  ||  '
';
                p_triggerCtr := p_triggerCtr + 1;
            end if;
          END LOOP;

  	     if ( p_triggerCtr = 0 ) then
	          l_depInfo := l_depInfo || '    None ' ||  '
';
   	     end if;

         sys.ad_dbms_metadata.close(l_triggerOpenHandle);

     else

	 	          l_depInfo := l_depInfo || '    None ' ||  '
';

     end if;

   end if;



      /* If the objType is table then try to get the sequence on it */

        if ( p_objMode = 'table' ) then
            l_depInfo := l_depInfo || 'Sequence(s) on ' || p_objName || ' : ' ||'
';
            get_xml_sequence(p_includeSequence,p_schemaName,p_sequenceCtr, l_seqListing,l_tmpXML);
             if(p_sequenceCtr = 0 ) then
                  l_depInfo := l_depInfo || '    None ' || '
' ;
            else
                   l_depInfo := l_depInfo  || l_seqListing  ;
            end if;
             if ( l_tmpXML is not null ) then
                  dbms_lob.append(l_finalXML,l_tmpXML);
             end if;
        end if;

   -- start of adusange code for policies generation.

        if ( p_objMode = 'table' or p_objMode = 'view' or p_objMode = 'synonym' ) then
            l_depInfo := l_depInfo || 'Policy(ies) on ' || p_objName || ' : ' || '
';

   -- Added by bhuvana. The p_includePolicy will contain the list of policies to include
            get_xml_policy(p_objName,p_schemaName,p_includePolicy,p_policyCtr, l_policyListing,l_tmpXML);
             if(p_policyCtr = 0 ) then
                  l_depInfo := l_depInfo || '    None ' ||  ' ';
            else
                   l_depInfo := l_depInfo  || l_policyListing  ||  ' ';
            end if;
             if ( l_tmpXML is not null ) then
                  dbms_lob.append(l_finalXML,l_tmpXML);
             end if;
        end if;
   --end of adusange code.


       /* get the comment Information */


        l_commentOpenHandle := sys.ad_dbms_metadata.open('COMMENT');
        sys.ad_dbms_metadata.set_filter(l_commentOpenHandle,'BASE_OBJECT_SCHEMA',p_schemaName);
        sys.ad_dbms_metadata.set_filter(l_commentOpenHandle,'BASE_OBJECT_NAME',p_objName);
        l_commentCtr := 0;

       LOOP
          begin
          l_commentXMLs := sys.ad_dbms_metadata.fetch_xml(l_commentOpenHandle);
          EXIT WHEN l_commentXMLs IS NULL;
          EXCEPTION
          when others then
          EXIT;
          end;
		  l_commentCtr := l_commentCtr + 1;
		  if ( l_commentCtr = 1 ) then
		       dbms_lob.append(l_finalXML,'<ROW>
');
		  end if;
		  l_eobjXMLs := XMLType.extract(l_commentXMLs,'ROWSET/ROW/COMMENT_T');
          l_tmpXML   := l_eobjXMLs.getClobVal();
          dbms_lob.append(l_finalXML,l_tmpXML);
       END LOOP;

       if ( l_commentCtr <> 0 ) then
	    dbms_lob.append(l_finalXML,'</ROW>
');
       end if;

       sys.ad_dbms_metadata.close(l_commentOpenHandle);



/*
       get_ddl_comment( p_objName,p_schemaName, l_tmpXML);
       if (  l_tmpXML is not null ) then
              dbms_lob.append(l_finalXML,l_tmpXML);
       end if;
*/

    END LOOP;

    end if;

    l_tmpXML := '</ROWSET>
';
   dbms_lob.append(l_finalXML,l_tmpXML);
   sys.ad_dbms_metadata.close(l_objOpenHandle);
   p_objInfo := l_depInfo;
   p_retXML := l_finalXML;


end odfgen_xml;


PROCEDURE get_xml_sequence(p_seqNameList        IN VARCHAR2,
                           p_schemaName         IN VARCHAR2,
                           p_seqCount        OUT NOCOPY NUMBER,
                           p_SeqListing      OUT NOCOPY VARCHAR2,
                           p_retVal          OUT NOCOPY CLOB)
IS
l_objXMLOpenHandle             NUMBER;
l_tablen                       BINARY_INTEGER;
l_seqList                      DBMS_UTILITY.UNCL_ARRAY;
finalInSt                      VARCHAR2(1000);
l_finalXML                     CLOB;
l_tmpXML                       CLOB;
l_eobjXMLs                     sys.XMLType;
l_sequenceXML                  sys.XMLType;
l_SeqName		       VARCHAR2(50);

BEGIN

/* the object name consists of comma separated sequence name */
/* Use it to form the in statement for set_filter method */
/* get in a pl/sql table */
      p_seqCount := 0;
      finalInSt := 'IN (';
      DBMS_UTILITY.COMMA_TO_TABLE(p_seqNameList,l_tabLen,l_seqList);
      for i in 1..l_tabLen loop
          finalInSt := finalInSt || '''' || l_seqList(i) || '''';
	        if ( i <> l_tabLen ) then
        	     finalInSt := finalInSt || ',';
      	  end if;
      end loop;
      finalInSt := finalInSt || ')';

      l_objXMLOpenHandle   := sys.ad_dbms_metadata.open('SEQUENCE');
      sys.ad_dbms_metadata.set_filter(l_objXMLOpenHandle,'SCHEMA',p_schemaName);
      sys.ad_dbms_metadata.set_filter(l_objXMLOpenHandle,'NAME_EXPR',finalInSt);

       LOOP
 --Amit Code.
          begin
          l_sequenceXML := sys.ad_dbms_metadata.fetch_xml(l_objXMLOpenHandle);
          EXIT WHEN l_sequenceXML IS NULL;
          EXCEPTION
          when others then
          p_seqCount := 0;
          EXIT;
          end;
          p_seqCount := p_seqCount + 1;
          l_eobjXMLs := XMLType.extract(l_sequenceXML,'ROWSET/ROW');
           SELECT extractValue(l_sequenceXML,'ROWSET/ROW/SEQUENCE_T/SCHEMA_OBJ/NAME')
          INTO   l_SeqName
          FROM DUAL;
          p_SeqListing := p_SeqListing || '    ' || l_SeqName || '
';
          l_tmpXML   := l_eobjXMLs.getClobVal();
          if ( l_finalXML is null ) then
              l_finalXML := l_tmpXML;
          else
              dbms_lob.append(l_finalXML,l_tmpXML);
          end if;
       END LOOP;

       sys.ad_dbms_metadata.close(l_objXMLOpenHandle);
       p_retVal := l_finalXML;




END get_xml_sequence;

--ADusange code to get all policies associated with table.

PROCEDURE get_xml_policy(p_tableName            IN VARCHAR2,
                           p_schemaName         IN VARCHAR2,
                           p_includePolicy      IN  VARCHAR2,
                           p_policyCount        OUT NOCOPY NUMBER,
                           p_PolicyListing      OUT NOCOPY VARCHAR2,
                           p_retVal             OUT NOCOPY CLOB)
IS
l_objXMLOpenHandle             NUMBER;
l_tablen                       BINARY_INTEGER;
l_policyList                   DBMS_UTILITY.UNCL_ARRAY;
finalInSt                      VARCHAR2(1000);
l_finalXML                     CLOB;
l_tmpXML                       CLOB;
l_eobjXMLs                     sys.XMLType;
l_policyXML                    sys.XMLType;
l_ctr                          NUMBER;
l_policyName		               VARCHAR2(50);

BEGIN

      l_ctr := 0;
      if ( p_includePolicy is null ) then
          l_ctr := 1;
      end if;

      p_policyCount := 0;
      l_objXMLOpenHandle   := sys.ad_dbms_metadata.open('RLS_POLICY');

      sys.ad_dbms_metadata.set_filter(l_objXMLOpenHandle,'BASE_OBJECT_SCHEMA',p_schemaName);
      sys.ad_dbms_metadata.set_filter(l_objXMLOpenHandle,'BASE_OBJECT_NAME',p_tableName);


       LOOP
          begin
          l_policyXML := sys.ad_dbms_metadata.fetch_xml(l_objXMLOpenHandle);
          EXIT WHEN l_policyXML IS NULL;
          EXCEPTION
          when others then
          p_policyCount := 0;
          EXIT;
          end;

          l_eobjXMLs := XMLType.extract(l_policyXML,'ROWSET/ROW');
          SELECT extractValue(l_policyXML,'ROWSET/ROW/RLS_POLICY_T/NAME')
          INTO   l_policyName
          FROM DUAL;

          if ((l_ctr = 1) or (instr(p_includePolicy,l_policyName) <> 0))  then
               p_policyCount := p_policyCount + 1;
               p_PolicyListing := p_PolicyListing || '    ' || l_policyName || '
';
               l_tmpXML   := l_eobjXMLs.getClobVal();
               if ( l_finalXML is null ) then
                    l_finalXML := l_tmpXML;
               else
                    dbms_lob.append(l_finalXML,l_tmpXML);
               end if;
          end if;
       END LOOP;

       sys.ad_dbms_metadata.close(l_objXMLOpenHandle);
       p_retVal := l_finalXML;

END get_xml_policy;



PROCEDURE get_fnd_table_metadata(p_tableName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_finalresult CLOB;
l_tmpresult CLOB;
BEGIN

     /* Extracting  metadata from fnd_tables and fnd_columns */
     get_fnd_tab_col_metadata(p_tableName,p_owner,p_ASNAME,l_finalresult);

     get_fnd_primary_key_metadata(p_tableName,p_owner,p_ASNAME,l_tmpresult);
     dbms_lob.append(l_finalresult,l_tmpresult);

     get_fnd_foreign_key_metadata(p_tableName,p_owner,p_ASNAME,l_tmpresult);
     dbms_lob.append(l_finalresult,l_tmpresult);

     get_fnd_histogram_metadata(p_tableName,p_owner,p_ASNAME,l_tmpresult);
     dbms_lob.append(l_finalresult,l_tmpresult);

     get_fnd_tablespace_metadata(p_tableName,p_owner,p_ASNAME,l_tmpresult);
     dbms_lob.append(l_finalresult,l_tmpresult);

     p_retXml := l_finalresult;

END get_fnd_table_metadata;

PROCEDURE get_fnd_view_metadata(p_viewName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result0   XmlType;
l_finalresult CLOB;
l_str       varchar2(2000);
l_refcur    SYS_REFCURSOR;
l_noOfRows  number;
l_ludate    varchar2(30);
BEGIN
 l_ludate := to_char(sysdate, 'YYYY/MM/DD');

 l_str := 'select fnd_load_util.owner_name(a.LAST_UPDATED_BY) as APPS_OWNER, ' ||
            ' to_char(a.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
            ' from fnd_views a, fnd_application b where view_name = :1 ' ||
            ' and  a.application_id = b.application_id ' ||
            ' and  b.application_short_name = :2 ';


 open l_refcur FOR l_str using p_viewName , p_asname;
 l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
 DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_AOL_METADATA');
 DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_VIEWS');


 l_result0 := DBMS_XMLGEN.getXMLType(l_queryCtx);

 l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
 if ( l_noOfRows = 0 ) then
       l_result0 := xmltype('<APPS_AOL_METADATA>
<APPS_FND_VIEWS>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_LAST_UPDATE_DATE>' || l_ludate || '</APPS_LAST_UPDATE_DATE>
</APPS_FND_VIEWS>
</APPS_AOL_METADATA>
');
 end if;

  l_finalresult := l_result0.getclobval();
  --printClobOut(l_finalresult);
  close l_refcur;
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..

  p_retXml := l_finalresult;

END get_fnd_view_metadata;


PROCEDURE get_fnd_mview_metadata(p_mviewName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_finalresult CLOB;
l_tmpresult CLOB;
BEGIN

     /* Extracting  metadata from fnd_tables and fnd_columns */
     get_fnd_tab_col_metadata(p_mviewName,p_owner,p_ASNAME,l_finalresult);

     get_fnd_histogram_metadata(p_mviewName,p_owner,p_ASNAME,l_tmpresult);
     dbms_lob.append(l_finalresult,l_tmpresult);

     p_retXml := l_finalresult;

END get_fnd_mview_metadata;

PROCEDURE is_temp_iot (   p_object_name        IN VARCHAR2,
                          p_schemaName         IN VARCHAR2,
                          p_type               OUT NOCOPY VARCHAR2) IS
l_str1      varchar2(50);
l_str2      varchar2(50);
ctr         NUMBER := 0;
cursor c_cur is
  select NVL(temporary, 'NO'), NVL(IOT_TYPE, 'NO')
  from dba_tables where table_name = p_object_name
  and owner = p_schemaName;
 begin
  open c_cur;
 loop
 fetch c_cur into l_str1 , l_str2;
 exit when c_cur%notfound;
 ctr := ctr + 1;
 end loop;
 close c_cur;
 if(ctr >=2 ) then
  p_type := '-1';
 elsif(l_str1 = 'Y' )  then -- Original condition:"l_str1 = 'N' or l_str1 = 'NO'".
    p_type := 'Y';
 elsif(l_str2 = 'IOT' or l_str2 = 'IOT_OVERFLOW') then
  -- Original condition : "l_str2 = 'NO'".
   p_type := 'Y';
 else
    p_type := 'N';
 end if;
end is_temp_iot;

PROCEDURE get_ddl_comment(p_ObjName            IN VARCHAR2,
                           p_schemaName         IN VARCHAR2,
                           p_retVal             OUT NOCOPY CLOB)
IS
l_objXMLOpenHandle             NUMBER;
transHandle                    NUMBER;
finalInSt                      VARCHAR2(1000);
l_finalXML                     CLOB;
l_tmpXML                       CLOB;
l_ddls                         sys.ku$_ddls;
l_ddl                          sys.ku$_ddl;
parsedItems                    sys.ku$_parsed_items;
l_ctr                          NUMBER;

BEGIN
      l_finalXML := null;
      l_ctr := 0;
      l_objXMLOpenHandle   := sys.ad_dbms_metadata.open('COMMENT');

      sys.ad_dbms_metadata.set_filter(l_objXMLOpenHandle,'BASE_OBJECT_NAME',p_ObjName);
      sys.ad_dbms_metadata.set_filter(l_objXMLOpenHandle,'BASE_OBJECT_SCHEMA',p_schemaName);
	  transHandle := sys.ad_dbms_metadata.add_transform(l_objXMLOpenHandle, 'DDL');
	  sys.ad_dbms_metadata.set_transform_param(transHandle,'SQLTERMINATOR', TRUE);



  --    sys.ad_dbms_metadata.set_parse_item(l_objXMLOpenHandle, 'NAME');




       LOOP
          begin
          l_ddls := sys.ad_dbms_metadata.fetch_ddl(l_objXMLOpenHandle);
          EXIT WHEN l_ddls IS NULL;
   --       EXCEPTION
   --       when others then
   --           l_ctr := 0;
   --            EXIT;
          end;

          l_ddl := l_ddls(1);
          if ( l_finalXML is null ) then
             l_finalXML := l_ddl.ddltext;
          else
             dbms_lob.append(l_finalXML,l_ddl.ddltext);
          end if;

       END LOOP;
       if ( l_finalXML is not null ) then
            l_tmpXML := '<ROW>
<COMMENT_T>
';
            dbms_lob.append(l_tmpXML,l_finalXML);
            dbms_lob.append(l_tmpXML,'</COMMENT_T>
');
            dbms_lob.append(l_tmpXML,'</ROW>
');
       end if;

       sys.ad_dbms_metadata.close(l_objXMLOpenHandle);
       p_retVal := l_tmpXML;

END get_ddl_comment;


PROCEDURE get_fnd_tab_col_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_queryCtx1 DBMS_XMLGEN.ctxType;
l_result0   XmlType;
l_result1   xmlType;
l_finalresult CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtabxml XMLType;
l_noOfRows  number;
l_ludate    varchar2(30);
l_comments  varchar2(240);
BEGIN
 l_ludate := to_char(sysdate, 'YYYY/MM/DD');
 begin
   select substr(ltrim(rtrim(comments)),1,240)
   into   l_comments
   from   dba_tab_comments
   where  owner = p_owner
   and    table_name = p_objName;
 exception
   when others then
     l_comments := '';
 end;

 l_str := 'select table_type as apps_table_type, ' ||
            ' NVL(a.description,:1) as APPS_DESCRIPTION, ' ||
            ' fnd_load_util.owner_name(a.LAST_UPDATED_BY) as APPS_OWNER, ' ||
            ' to_char(a.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
            ' from fnd_tables a, fnd_application b where table_name = :2 ' ||
            ' and  a.application_id = b.application_id ' ||
            ' and  b.application_short_name = :3 ';

 open l_refcur FOR l_str using l_comments, p_objName , p_asname;
 l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
 DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_AOL_METADATA');
 DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_TABLES');


 l_result0 := DBMS_XMLGEN.getXMLType(l_queryCtx);

 l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
 if ( l_noOfRows <> 0 ) then
       l_fndtabxml := xmltype.extract(l_result0,'APPS_AOL_METADATA/APPS_FND_TABLES');
 else
       l_fndtabxml := xmltype('<APPS_FND_TABLES>
<APPS_TABLE_TYPE>T</APPS_TABLE_TYPE>
<APPS_DESCRIPTION>'||l_comments||'</APPS_DESCRIPTION>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_LAST_UPDATE_DATE>' || l_ludate || '</APPS_LAST_UPDATE_DATE>
</APPS_FND_TABLES>
');
 end if;

  l_finalresult := l_fndtabxml.getclobval();
  --printClobOut(l_finalresult);
  close l_refcur;
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..

  if ( l_noOfRows = 0 ) then
    l_str := 'select column_name as apps_column_name, ' ||
                ' nvl((select nvl(substr(ltrim(rtrim(c.comments)), 1, 240),'' '') '||
                ' from dba_col_comments c ' ||
                '     where c.owner = a.owner ' ||
                '     and   c.table_name = a.table_name ' ||
                '     and   c.column_name = a.column_name), '' '') as APPS_DESCRIPTION, ' ||
                '''N'' as APPS_TRANSLATE_FLAG , ' ||
                '''N'' as APPS_FLEXFIELD_USAGE_CODE, ' ||
                ''' '' as APPS_FLEXFIELD_APP_ID, ' ||
                ''' '' as APPS_FLEXFIELD_NAME, ' ||
                '''SEED'' as APPS_OWNER, ' ||
                ' to_char(sysdate, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
                'FROM dba_tab_cols a where a.table_name = :1 ' ||
                'and a.owner  = :2 order by column_id';
    open l_refcur for  l_str using p_objName, p_owner;
  else

/*
    l_str := 'select column_name as apps_column_name, ' ||
             ' NVL(description,'' '') as APPS_DESCRIPTION, '
                'TRANSLATE_FLAG as APPS_TRANSLATE_FLAG , ' ||
                'FLEXFIELD_USAGE_CODE as APPS_FLEXFIELD_USAGE_CODE, ' ||
                'NVL(TO_CHAR(FLEXFIELD_APPLICATION_ID),'' '') as APPS_FLEXFIELD_APP_ID, ' ||
                'NVL(FLEXFIELD_NAME,'' '') as APPS_FLEXFIELD_NAME, ' ||
                ' fnd_load_util.owner_name(a.LAST_UPDATED_BY) as APPS_OWNER, ' ||
                ' to_char(a.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
                'FROM fnd_tables a, fnd_columns b, fnd_application c ' ||
                '  where a.table_name = :1 ' ||
                ' and c.application_short_name = :2 ' ||
                'and a.table_id  = b.table_id ' ||
                'and a.application_id = b.application_id ' ||
                'and b.application_id = c.application_id ' ||
                'order by column_sequence';
    open l_refcur for  l_str using p_objName, p_asname;
*/
-- start : rsekaran code
-- Enhancement that will generate the AOL metadata for FND_COLUMNS with default values
-- if the metadata doesn't exists in the DB.

-- Mladena - change for performance only

	l_str := 'select column_name as apps_column_name, '||
     '   NVL(b.description,'' '') as APPS_DESCRIPTION, '||
	 'TRANSLATE_FLAG as APPS_TRANSLATE_FLAG ,  '||
	 'FLEXFIELD_USAGE_CODE as APPS_FLEXFIELD_USAGE_CODE,  '||
	 'NVL(TO_CHAR(FLEXFIELD_APPLICATION_ID),'' '') as APPS_FLEXFIELD_APP_ID,  '||
	 'NVL(FLEXFIELD_NAME,'' '') as APPS_FLEXFIELD_NAME,  '||
	 '  fnd_load_util.owner_name(a.LAST_UPDATED_BY) as APPS_OWNER,  '||
	 '  to_char(a.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE '||
	 '  FROM  fnd_tables a, fnd_columns b, fnd_application c  '||
	 '  where a.table_name = :tabname  '||
	 '  and   c.application_short_name = :tabowner  '||
	 '  and   a.table_id  = b.table_id  '||
	 '  and   a.application_id = b.application_id '||
	 '  and   b.application_id = c.application_id '||
 'UNION  '||
 ' select  '||
'	dbacol.column_name as apps_column_name,  '||
'        nvl((select nvl(substr(ltrim(rtrim(c.comments)),1,240),'' '') '||
'           from dba_col_comments c  '||
'           where c.owner = dbacol.owner  '||
'           and   c.table_name = dbacol.table_name  '||
'           and   c.column_name = dbacol.column_name), '' '') as APPS_DESCRIPTION,  '||
'	 ''N'' as APPS_TRANSLATE_FLAG,  '||
'	 ''N'' AS APPS_FLEXFIELD_USAGE_CODE, '||
'	 '' '' AS APPS_FLEXFIELD_APP_ID, '||
'	 '' '' AS APPS_FLEXFIELD_NAME,  '||
'	 fnd_load_util.owner_name(fndtab.LAST_UPDATED_BY) AS APPS_OWNER, '||
'         to_char(fndtab.LAST_UPDATE_DATE, ''YYYY/MM/DD'') AS APPS_LAST_UPDATE_DATE  '||
' from  '||
'	dba_tab_columns dbacol, fnd_tables fndtab, fnd_application fndapp '||
' where  '||
'	dbacol.table_name     = :tabname  '||
'	and dbacol.owner      = :tabowner  '||
'	and dbacol.table_name = fndtab.table_name '||
'	and fndtab.table_name = :tabname  '||
'	and fndapp.application_short_name = :tabowner '||
'	and fndtab.application_id = fndapp.application_id '||
'	and not exists '||
'	   (select 1 '||
'	      from fnd_columns fndcol, '||
'		   fnd_tables  fndtab, '||
'		   fnd_application fndapp '||
'	    where  dbacol.column_name    = fndcol.column_name '||
'	      and  fndcol.table_id       = fndtab.table_id '||
'	      and  fndcol.application_id = fndtab.application_id '||
'	      and  fndtab.table_name     = :tabname '||
'  	      and  fndtab.application_id = fndapp.application_id '||
'  	      and  fndapp.application_short_name = :tabowner  )';


open l_refcur for  l_str using p_objName, p_asname, p_objName, p_asname, p_objName, p_asname, p_objName, p_asname;

-- end : rsekaran code

  end if;


  l_queryCtx1 := DBMS_XMLGEN.newContext(l_refcur);
  DBMS_XMLGEN.setRowsetTag(l_queryCtx1,'APPS_FND_COLUMNS');
  DBMS_XMLGEN.setRowTag(l_queryCtx1,'APPS_FND_COLUMN_ITEM');


  -- get the result..!
  l_result1:= DBMS_XMLGEN.getXMLType(l_queryCtx1);
  l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx1);
  if(l_noOfRows = 0) then
  l_fndtabxml := xmlType('<APPS_FND_COLUMNS>
<APPS_FND_COLUMN_ITEMS>
<APPS_FND_COLUMN_NAME></APPS_FND_COLUMN_NAME>
<APPS_DESCRIPTION></APPS_DESCRIPTION>
<APPS_FND_COLUMN_SEQUENCE></APPS_FND_COLUMN_SEQUENCE>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_FND_COLUMN_UPDATE_DATE>'|| l_ludate ||'</APPS_FND_COLUMN_UPDATE_DATE>
</APPS_FND_COLUMN_ITEMS>
</APPS_FND_COLUMNS> ');
     dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());
  else
  l_fndtabxml := xmltype.extract(l_result1,'APPS_FND_COLUMNS');
  dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());
end if;

  DBMS_XMLGEN.closeContext(l_queryCtx1);  -- you must close the query handle..
  close l_refcur;

  p_retXml := l_finalresult;

End get_fnd_tab_col_metadata;

PROCEDURE get_fnd_primary_key_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result1   xmlType;
l_finalresult CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtabxml XMLType;
l_noOfRows  number;
l_ludate    varchar2(30);
BEGIN

 l_ludate := to_char(sysdate, 'YYYY/MM/DD');
  /* get the primary key info */

  l_str := 'select PRIMARY_KEY_NAME as APPS_PRIMARY_KEY_NAME, ' ||
                'NVL(P.DESCRIPTION,'' '') as APPS_DESCRIPTION, ' ||
                'PRIMARY_KEY_TYPE as apps_primary_key_type, ' ||
                'AUDIT_KEY_FLAG   as APPS_AUDIT_KEY_FLAG, ' ||
                ' fnd_load_util.owner_name(P.LAST_UPDATED_BY) as APPS_OWNER, ' ||
                ' to_char(P.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
                'from   FND_TABLES T, ' ||
                'FND_APPLICATION A, ' ||
                'FND_PRIMARY_KEYS P ' ||
                'where  A.APPLICATION_ID = T.APPLICATION_ID ' ||
                'and    A.APPLICATION_SHORT_NAME = :1 ' ||
                'and    T.TABLE_NAME = :2 ' ||
                'and    P.TABLE_ID = T.TABLE_ID ' ||
                'and    P.APPLICATION_ID = T.APPLICATION_ID ' ||
                'order by 1 ';

  open l_refcur for  l_str using p_asname, p_objName;
  l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
  DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_FND_PRIMARY_KEYS');
  DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_PRIMARY_KEY_ITEMS');
  l_result1:= DBMS_XMLGEN.getXMLType(l_queryCtx);
  l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
  if ( l_noOfRows <> 0 ) then
       l_fndtabxml := xmltype.extract(l_result1,'APPS_FND_PRIMARY_KEYS');
        l_finalresult := l_fndtabxml.getclobval();
  else
       l_fndtabxml := xmlType('<APPS_FND_PRIMARY_KEYS>
<APPS_FND_PRIMARY_KEY_ITEMS>
<APPS_PRIMARY_KEY_NAME></APPS_PRIMARY_KEY_NAME>
<APPS_DESCRIPTION></APPS_DESCRIPTION>
<APPS_AUDIT_KEY_FLAG>N</APPS_AUDIT_KEY_FLAG>
<APPS_PRIMARY_KEY_TYPE>D</APPS_PRIMARY_KEY_TYPE>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_LAST_UPDATE_DATE>'|| l_ludate ||'</APPS_LAST_UPDATE_DATE>
</APPS_FND_PRIMARY_KEY_ITEMS>
</APPS_FND_PRIMARY_KEYS>
');
    l_finalresult := l_fndtabxml.getclobval();
  end if;
  --printClobOut(l_finalresult);
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..
  close l_refcur;


/* get the primary key column info */
  if ( l_noOfRows <> 0 ) then

  l_str := ' select P.PRIMARY_KEY_NAME AS APPS_PRIMARY_KEY_NAME,  ' ||
         ' C.COLUMN_NAME AS APPS_PK_COLUMN_NAME, ' ||
         ' PC.PRIMARY_KEY_SEQUENCE AS APPS_PK_COLUMN_SEQUENCE, ' ||
         ' fnd_load_util.owner_name(PC.LAST_UPDATED_BY) as APPS_OWNER, ' ||
         ' to_char(PC.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
         ' from   FND_COLUMNS C, ' ||
         '        FND_PRIMARY_KEYS P, ' ||
         '        FND_PRIMARY_KEY_COLUMNS PC, ' ||
         '        FND_TABLES T, ' ||
         '        FND_APPLICATION A ' ||
         'where  A.APPLICATION_SHORT_NAME = :1 ' ||
         'and    T.APPLICATION_ID = A.APPLICATION_ID ' ||
         'and    T.TABLE_NAME = :2 ' ||
         'and    P.TABLE_ID = T.TABLE_ID ' ||
         'and    P.APPLICATION_ID = T.APPLICATION_ID ' ||
         'and    PC.APPLICATION_ID = P.APPLICATION_ID ' ||
         'and    PC.TABLE_ID = P.TABLE_ID ' ||
         'and    PC.PRIMARY_KEY_ID = P.PRIMARY_KEY_ID ' ||
         'and    C.APPLICATION_ID = PC.APPLICATION_ID ' ||
         'and    C.TABLE_ID = PC.TABLE_ID ' ||
         'and    C.COLUMN_ID = PC.COLUMN_ID   ' ||
         'order by 1 ';


  open l_refcur for  l_str using p_asname, p_objName;
  l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
  DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_FND_PK_COLUMNS');
  DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_PK_COLUMN_ITEMS');
  l_result1:= DBMS_XMLGEN.getXMLType(l_queryCtx);
  l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
  if ( l_noOfRows <> 0 ) then
       l_fndtabxml := xmltype.extract(l_result1,'APPS_FND_PK_COLUMNS');
       dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());
  end if;
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..
  close l_refcur;

  end if;

  if ( l_noOfRows = 0 ) then
       l_fndtabxml := xmlType('<APPS_FND_PK_COLUMNS>
<APPS_FND_PK_COLUMN_ITEMS>
<APPS_PRIMARY_KEY_NAME></APPS_PRIMARY_KEY_NAME>
<APPS_PK_COLUMN_NAME></APPS_PK_COLUMN_NAME>
<APPS_PK_COLUMN_SEQUENCE></APPS_PK_COLUMN_SEQUENCE>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_LAST_UPDATE_DATE>'|| l_ludate ||'</APPS_LAST_UPDATE_DATE>
</APPS_FND_PK_COLUMN_ITEMS>
</APPS_FND_PK_COLUMNS>
');
     dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());

  end if;

  --printClobOut(l_finalresult);
 p_retXml := l_finalresult;

End get_fnd_primary_key_metadata;

PROCEDURE get_fnd_foreign_key_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result1   xmlType;
l_finalresult CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtabxml XMLType;
l_noOfRows  number;
l_ludate    varchar2(30);
BEGIN

 l_ludate := to_char(sysdate, 'YYYY/MM/DD');

/* Get the foreign key info */

    l_str := 'select F.FOREIGN_KEY_NAME as APPS_FOREIGN_KEY_NAME, ' ||
           ' PA.APPLICATION_SHORT_NAME as APPS_PK_APP_SHORT_NAME, ' ||
           ' PT.TABLE_NAME as APPS_PK_TABLE_NAME, ' ||
           ' P.PRIMARY_KEY_NAME as APPS_PK_NAME, ' ||
 	   ' NVL(F.DESCRIPTION,'' '') as APPS_DESCRIPTION, ' ||
           ' F.CASCADE_BEHAVIOR as APPS_CASCADE_BEHAVIOR, ' ||
           ' F.FOREIGN_KEY_RELATION as APPS_FK_RELATION, ' ||
           ' F.CONDITION AS APPS_CONDITION, ' ||
           ' fnd_load_util.owner_name(F.LAST_UPDATED_BY) as APPS_OWNER, ' ||
           ' to_char(F.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
    ' from   FND_TABLES T, ' ||
           ' FND_APPLICATION A, ' ||
           ' FND_FOREIGN_KEYS F, ' ||
           ' FND_APPLICATION PA, ' ||
           ' FND_TABLES PT, ' ||
           ' FND_PRIMARY_KEYS P ' ||
    ' where  A.APPLICATION_ID = T.APPLICATION_ID ' ||
    ' and    A.APPLICATION_SHORT_NAME = :1 ' ||
    ' and    T.TABLE_NAME = :2 ' ||
    ' and    F.TABLE_ID = T.TABLE_ID ' ||
    ' and    F.APPLICATION_ID = T.APPLICATION_ID     ' ||
    ' and    F.PRIMARY_KEY_APPLICATION_ID = PA.APPLICATION_ID ' ||
    ' and    F.PRIMARY_KEY_TABLE_ID = PT.TABLE_ID ' ||
    ' and    F.PRIMARY_KEY_APPLICATION_ID = PT.APPLICATION_ID ' ||
    ' and    F.PRIMARY_KEY_TABLE_ID = P.TABLE_ID ' ||
    ' and    F.PRIMARY_KEY_APPLICATION_ID = P.APPLICATION_ID ' ||
    ' and    F.PRIMARY_KEY_ID = P.PRIMARY_KEY_ID ' ||
    ' order by 1 ';

  open l_refcur for  l_str using p_asname, p_objName;
  l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
  DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_FND_FOREIGN_KEYS');
  DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_FOREIGN_KEY_ITEMS');
  l_result1:= DBMS_XMLGEN.getXMLType(l_queryCtx);
  l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
  if ( l_noOfRows <> 0 ) then
       l_fndtabxml := xmltype.extract(l_result1,'APPS_FND_FOREIGN_KEYS');
       l_finalresult := l_fndtabxml.getclobval();
  else
       l_fndtabxml := xmlType('<APPS_FND_FOREIGN_KEYS>
<APPS_FND_FOREIGN_KEY_ITEMS>
<APPS_FOREIGN_KEY_NAME></APPS_FOREIGN_KEY_NAME>
<APPS_PK_APP_SHORT_NAME></APPS_PK_APP_SHORT_NAME>
<APPS_PK_TABLE_NAME></APPS_PK_TABLE_NAME>
<APPS_PK_NAME></APPS_PK_NAME>
<APPS_DESCRIPTION></APPS_DESCRIPTION>
<APPS_CASCADE_BEHAVIOR></APPS_CASCADE_BEHAVIOR>
<APPS_FK_RELATION></APPS_FK_RELATION>
<APPS_CONDITION></APPS_CONDITION>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_LAST_UPDATE_DATE>'|| l_ludate ||'</APPS_LAST_UPDATE_DATE>
</APPS_FND_FOREIGN_KEY_ITEMS>
</APPS_FND_FOREIGN_KEYS>
');
     l_finalresult := l_fndtabxml.getclobval();
  end if;
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..
  close l_refcur;


  if ( l_noOfRows <> 0 ) then
    /* Get the foreign key columns */

    l_str := ' select F.FOREIGN_KEY_NAME AS APPS_FK_NAME,  ' ||
           ' C.COLUMN_NAME as APPS_PK_COLUMN_NAME,  ' ||
           ' FC.FOREIGN_KEY_SEQUENCE as APPS_FK_SEQUENCE,  ' ||
           ' FC.CASCADE_VALUE  as APPS_CASCADE_VALUE, ' ||
           ' fnd_load_util.owner_name(FC.LAST_UPDATED_BY) as APPS_OWNER, ' ||
           ' to_char(FC.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
    ' from   FND_COLUMNS C,  ' ||
           ' FND_FOREIGN_KEYS F,  ' ||
           ' FND_FOREIGN_KEY_COLUMNS FC,  ' ||
           ' FND_TABLES T,  ' ||
           ' FND_APPLICATION A  ' ||
    ' where  A.APPLICATION_SHORT_NAME = :1   ' ||
    ' and    T.APPLICATION_ID = A.APPLICATION_ID  ' ||
    ' and    T.TABLE_NAME = :2  ' ||
    ' and    F.TABLE_ID = T.TABLE_ID  ' ||
    ' and    F.APPLICATION_ID = T.APPLICATION_ID ' ||
    ' and    FC.APPLICATION_ID = F.APPLICATION_ID  ' ||
    ' and    FC.TABLE_ID = F.TABLE_ID  ' ||
    ' and    FC.FOREIGN_KEY_ID = F.FOREIGN_KEY_ID  ' ||
    ' and    C.APPLICATION_ID = FC.APPLICATION_ID  ' ||
    ' and    C.TABLE_ID = FC.TABLE_ID  ' ||
    ' and    C.COLUMN_ID = FC.COLUMN_ID  ' ||
    ' order by 1  ';

  open l_refcur for  l_str using p_asname, p_objName;
  l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
  DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_FND_FK_COLUMNS');
  DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_FK_COLUMN_ITEMS');
  l_result1:= DBMS_XMLGEN.getXMLType(l_queryCtx);
  l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
  if ( l_noOfRows <> 0 ) then
       l_fndtabxml := xmltype.extract(l_result1,'APPS_FND_FK_COLUMNS');
       dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());
  end if;
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..
  close l_refcur;

end if;

 if ( l_noOfRows = 0 ) then
  l_fndtabxml := xmlType('<APPS_FND_FK_COLUMNS>
<APPS_FND_FK_COLUMN_ITEMS>
<APPS_FK_NAME></APPS_FK_NAME>
<APPS_FK_SEQUENCE></APPS_FK_SEQUENCE>
<APPS_CASCADE_VALUE></APPS_CASCADE_VALUE>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_LAST_UPDATE_DATE>'|| l_ludate ||'</APPS_LAST_UPDATE_DATE>
</APPS_FND_FK_COLUMN_ITEMS>
</APPS_FND_FK_COLUMNS>
');
     dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());
  end if;


 p_retXml := l_finalresult;

End get_fnd_foreign_key_metadata;

PROCEDURE get_fnd_histogram_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result1   xmlType;
l_finalresult CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtabxml XMLType;
l_noOfRows  number;
l_ludate    varchar2(30);
--l_comments  varchar2(240);
BEGIN

 l_ludate := to_char(sysdate, 'YYYY/MM/DD');

l_str := ' select C.COLUMN_NAME AS APPS_COLUMN_NAME, ' ||
         ' C.PARTITION AS APPS_PARTITION, ' ||
         ' C.HSIZE AS APPS_HSIZE, ' ||
         ' fnd_load_util.owner_name(C.LAST_UPDATED_BY) as APPS_OWNER, ' ||
         ' to_char(C.LAST_UPDATE_DATE, ''YYYY/MM/DD'') as APPS_LAST_UPDATE_DATE ' ||
   ' from   FND_HISTOGRAM_COLS C, ' ||
          ' FND_TABLES T, ' ||
          ' FND_APPLICATION A ' ||
   ' where  A.APPLICATION_ID = T.APPLICATION_ID ' ||
   ' and    A.APPLICATION_SHORT_NAME = :1 ' ||
   ' and    T.TABLE_NAME = C.TABLE_NAME ' ||
   ' and    T.TABLE_NAME = :2 ' ||
   ' and    C.APPLICATION_ID = T.APPLICATION_ID ' ||
   ' order by 1 ';

  open l_refcur for  l_str using p_asname, p_objName;
  l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
  DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_FND_HISTOGRAM');
  DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_HISTOGRAM_ITEMS');
  l_result1:= DBMS_XMLGEN.getXMLType(l_queryCtx);
  l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
  if ( l_noOfRows <> 0 ) then
       l_fndtabxml := xmltype.extract(l_result1,'APPS_FND_HISTOGRAM');
         l_finalresult := l_fndtabxml.getclobval();
  else
     l_fndtabxml := xmlType('<APPS_FND_HISTOGRAM>
<APPS_FND_HISTOGRAM_ITEMS>
<APPS_COLUMN_NAME></APPS_COLUMN_NAME>
<APPS_PARTITION></APPS_PARTITION>
<APPS_HSIZE></APPS_HSIZE>
<APPS_OWNER>SEED</APPS_OWNER>
<APPS_LAST_UPDATE_DATE>'|| l_ludate ||'</APPS_LAST_UPDATE_DATE>
</APPS_FND_HISTOGRAM_ITEMS>
</APPS_FND_HISTOGRAM>
');
     l_finalresult := l_fndtabxml.getclobval();
  end if;

  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..
  close l_refcur;

--  printClobOut(l_finalresult);

p_retXml := l_finalresult;

End get_fnd_histogram_metadata;


PROCEDURE get_fnd_tablespace_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result1   xmlType;
l_finalresult CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtabxml XMLType;
l_noOfRows  number;
BEGIN
  /* get the tablespace info */

  l_finalresult := TO_CLOB('<!-- Choose from one of the following tablespace '||
                                'types to classify storage -
                                TRANSACTION_TABLES
                                REFERENCE
                                INTERFACE
                                SUMMARY
                                NOLOGGING
                                TRANSACTION_INDEXES
                                ARCHIVE
                                MEDIA
                                TOOLS
-->');

  l_str := 'select tablespace_type as APPS_TABLESPACE_CLASSIFICATION ' ||
           ' FROM FND_OBJECT_TABLESPACES T, ' ||
           ' FND_APPLICATION A ' ||
           ' where  A.APPLICATION_ID = T.APPLICATION_ID ' ||
           ' and    A.APPLICATION_SHORT_NAME = :1 ' ||
           ' and object_name = :2    ';

  /*
  l_str := 'select decode(TABLESPACE_TYPE,''TRANSACTION_TABLES'',''Y'',''N'') '||
           ' as APPS_TSPACE_TX_TABLES , ' ||
           ' decode(TABLESPACE_TYPE,''REFERENCE'',''Y'',''N'') '||
           ' as APPS_TSPACE_REFERENCE , ' ||
           ' decode(TABLESPACE_TYPE,''INTERFACE'',''Y'',''N'') '||
           ' as APPS_TSPACE_INTERFACE , ' ||
           ' decode(TABLESPACE_TYPE,''SUMMARY'',''Y'',''N'') '||
           ' as APPS_TSPACE_SUMMARY , ' ||
           ' decode(TABLESPACE_TYPE,''NOLOGGING'',''Y'',''N'') '||
           ' as APPS_TSPACE_NOLOGGING , ' ||
           ' decode(TABLESPACE_TYPE,''TRANSACTION_INDEXES'',''Y'',''N'') '||
           ' as APPS_TSPACE_TX_INDEXES , ' ||
           ' decode(TABLESPACE_TYPE,''ARCHIVE'',''Y'',''N'') '||
           ' as APPS_TSPACE_ARCHIVE  ' ||
           ' FROM FND_OBJECT_TABLESPACES T, ' ||
           ' FND_APPLICATION A ' ||
           ' where  A.APPLICATION_ID = T.APPLICATION_ID ' ||
           ' and    A.APPLICATION_SHORT_NAME = :1 ' ||
           ' and object_name = :2    ';
  */

  open l_refcur for  l_str using p_asname, p_objName;
  l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
  DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_FND_OBJECT_TS');
  DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_FND_OBJECT_TABLESPACE');
  l_result1:= DBMS_XMLGEN.getXMLType(l_queryCtx);
  l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
  if ( l_noOfRows <> 0 ) then
       l_fndtabxml := xmltype.extract(l_result1,'APPS_FND_OBJECT_TS/APPS_FND_OBJECT_TABLESPACE');
       dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());
  else
  /*
     l_fndtabxml := xmlType('<APPS_FND_OBJECT_TABLESPACE>
<APPS_TSPACE_TX_TABLES>N</APPS_TSPACE_TX_TABLES>
<APPS_TSPACE_REFERENCE>N</APPS_TSPACE_REFERENCE>
<APPS_TSPACE_INTERFACE>N</APPS_TSPACE_INTERFACE>
<APPS_TSPACE_SUMMARY>N</APPS_TSPACE_SUMMARY>
<APPS_TSPACE_NOLOGGING>N</APPS_TSPACE_NOLOGGING>
<APPS_TSPACE_TX_INDEXES>N</APPS_TSPACE_TX_INDEXES>
<APPS_TSPACE_ARCHIVE>N</APPS_TSPACE_ARCHIVE>
</APPS_FND_OBJECT_TABLESPACE>
');
  */

     l_fndtabxml := xmlType('<APPS_FND_OBJECT_TABLESPACE>
<APPS_TABLESPACE_CLASSIFICATION>TRANSACTION_TABLES</APPS_TABLESPACE_CLASSIFICATION>
 </APPS_FND_OBJECT_TABLESPACE>
');
     dbms_lob.append(l_finalresult,l_fndtabxml.getclobval());

  end if;

  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..
  close l_refcur;

p_retXml := l_finalresult;

End get_fnd_tablespace_metadata;


/* vkhatri bug 4929568 */
PROCEDURE get_type_attr(p_typeName      IN  VARCHAR2,
                        p_owner          IN  VARCHAR2,
                        p_ASNAME         IN  VARCHAR2,
                        p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result   XmlType;
l_finalresult CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtypexml XMLType;
l_noOfRows  number;
BEGIN

 l_str := 'select ATTR_NAME as ATTRIBUTE_NAME, ' ||
	' NVL(ATTR_TYPE_OWNER,'' '') as ATTR_TYPE_OWNER, ' ||
	' ATTR_TYPE_NAME as ATTR_TYPE_NAME, ' ||
	' NVL(TO_CHAR(LENGTH),'' '') as LENGTH, ' ||
	' NVL(TO_CHAR(PRECISION),'' '') as PRECISION, ' ||
	' NVL(TO_CHAR(SCALE),'' '') as SCALE, ' ||
	' INHERITED as INHERITED ' ||
	' from ALL_TYPE_ATTRS where owner=:1 and type_name=:2 ';

 open l_refcur FOR l_str using  p_owner, p_typeName;
 l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
 DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_TYPE_ATTRIBUTE');
 DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_TYPE_ATTRIBUTE_ITEMS');

 l_result := DBMS_XMLGEN.getXMLType(l_queryCtx);

 l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
 if ( l_noOfRows <> 0 ) then
       l_fndtypexml := xmltype.extract(l_result,'APPS_TYPE_ATTRIBUTE');
else
	l_fndtypexml := xmlType('<APPS_TYPE_ATTRIBUTE></APPS_TYPE_ATTRIBUTE>
');
 end if;

  l_finalresult := l_fndtypexml.getclobval();

  close l_refcur;
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..

  p_retXml := l_finalresult;

END get_type_attr;


/* vkhatri bug 4929568 */
PROCEDURE get_type_method(p_typeName      IN  VARCHAR2,
                          p_owner          IN  VARCHAR2,
                          p_ASNAME         IN  VARCHAR2,
                          p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result   XmlType;
l_finalresult CLOB;
l_tmpXML CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtypexml XMLType;
l_noOfRows  number;
BEGIN

 l_str := 'select METHOD_NAME as METHOD_NAME, ' ||
	' METHOD_NO as METHOD_NO, ' ||
	' METHOD_TYPE as METHOD_TYPE, ' ||
	' PARAMETERS as PARAMETERS, ' ||
	' RESULTS as RESULTS, ' ||
	' FINAL as FINAL, ' ||
	' INSTANTIABLE as INSTANTIABLE, ' ||
	' OVERRIDING as OVERRIDING, ' ||
	' INHERITED as INHERITED ' ||
	' from ALL_TYPE_METHODS where owner=:1 and type_name=:2';

 open l_refcur FOR l_str using  p_owner, p_typeName;
 l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
 DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_TYPE_METHOD');
 DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_TYPE_METHOD_ITEMS');

 l_result := DBMS_XMLGEN.getXMLType(l_queryCtx);

 l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
 if ( l_noOfRows <> 0 ) then
       l_fndtypexml := xmltype.extract(l_result,'APPS_TYPE_METHOD');
 else
       l_fndtypexml := xmlType('<APPS_TYPE_METHOD></APPS_TYPE_METHOD>
');
 end if;

  l_finalresult := l_fndtypexml.getclobval();

  close l_refcur;
  DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..

 if ( l_noOfRows <> 0 ) then
	get_type_method_params_results(p_typeName,p_owner,p_ASNAME,l_tmpXML);
        dbms_lob.append(l_finalresult,l_tmpXML);
 end if;

  p_retXml := l_finalresult;

END get_type_method;


/* vkhatri bug 4929568 */
PROCEDURE get_type_method_params_results(p_typeName      IN  VARCHAR2,
                          p_owner          IN  VARCHAR2,
                          p_ASNAME         IN  VARCHAR2,
                          p_retXml         OUT NOCOPY CLOB)
IS
l_queryCtx  DBMS_XMLGEN.ctxType;
l_result   XmlType;
l_finalresult CLOB;
l_tmpXML CLOB;
l_str       varchar2(2500);
l_refcur    SYS_REFCURSOR;
l_fndtypexml XMLType;
l_noOfRows  number;
BEGIN

 l_str := 'select METHOD_NAME as METHOD_NAME, ' ||
 	' METHOD_NO as METHOD_NO, ' ||
	' PARAM_NAME as PARAM_NAME, ' ||
	' PARAM_NO as PARAM_NO, ' ||
	' PARAM_MODE as PARAM_MODE, ' ||
	' PARAM_TYPE_OWNER as PARAM_TYPE_OWNER, ' ||
	' PARAM_TYPE_NAME as PARAM_TYPE_NAME ' ||
	' from ALL_METHOD_PARAMS  where owner=:1 and type_name=:2';

 open l_refcur FOR l_str using  p_owner, p_typeName;
 l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
 DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_TYPE_METHOD_PARAM');
 DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_TYPE_METHOD_PARAM_ITEMS');

 l_result := DBMS_XMLGEN.getXMLType(l_queryCtx);

 l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
 if ( l_noOfRows <> 0 ) then
       l_fndtypexml := xmltype.extract(l_result,'APPS_TYPE_METHOD_PARAM');
 else
       l_fndtypexml := xmlType('<APPS_TYPE_METHOD_PARAM></APPS_TYPE_METHOD_PARAM>
');
 end if;

 l_finalresult := l_fndtypexml.getclobval();

 close l_refcur;
 DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle..


 l_str := 'select METHOD_NAME as METHOD_NAME, ' ||
	' METHOD_NO as METHOD_NO, ' ||
	' NVL(RESULT_TYPE_OWNER,'' '') as RESULT_TYPE_OWNER, ' ||
	' RESULT_TYPE_NAME as RESULT_TYPE_NAME ' ||
	' from ALL_METHOD_RESULTS  where owner=:1 and type_name=:2';

 open l_refcur FOR l_str using  p_owner, p_typeName;
 l_queryCtx := DBMS_XMLGEN.newContext(l_refcur);
 DBMS_XMLGEN.setRowsetTag(l_queryCtx,'APPS_TYPE_METHOD_RESULT');
 DBMS_XMLGEN.setRowTag(l_queryCtx,'APPS_TYPE_METHOD_RESULT_ITEMS');

 l_result := DBMS_XMLGEN.getXMLType(l_queryCtx);

 l_noOfRows := DBMS_XMLGEN.getNumRowsProcessed(l_queryCtx);
 if ( l_noOfRows <> 0 ) then
       l_fndtypexml := xmltype.extract(l_result,'APPS_TYPE_METHOD_RESULT');
 else
       l_fndtypexml := xmlType('<APPS_TYPE_METHOD_RESULT></APPS_TYPE_METHOD_RESULT>
');
 end if;

  l_tmpXML := l_fndtypexml.getclobval();

 close l_refcur;
 DBMS_XMLGEN.closeContext(l_queryCtx);  -- you must close the query handle

 dbms_lob.append(l_finalresult,l_tmpXML);

 p_retXml := l_finalresult;

END get_type_method_params_results;

end fnd_odf_gen;


/
