--------------------------------------------------------
--  DDL for Package Body DOM_REPOS_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_REPOS_MIG_PKG" AS
/* $Header: DOMVRUGB.pls 120.1 2006/09/04 16:17:27 rkhasa noship $ */

PROCEDURE UPDATE_PATH (
  p_short_name IN VARCHAR2,
  p_domain IN VARCHAR2,
  p_old_str IN varchar2,
  p_new_str IN OUT NOCOPY varchar2,
  x_msg IN OUT NOCOPY CLOB
  --p_isNewTable IN NUMBER
) IS
    --str_count NUMBER ;
    doc_id NUMBER;
    old_path VARCHAR2(1000);
    new_path VARCHAR2(1000);
    repos_id NUMBER ;
    dot_index NUMBER ;    --used to check if old string is of type firs.last
    newline_char VARCHAR2(2) ;
    old_dav_url varchar2(240);
    old_service_url varchar2(240);
    idx1 number;
    idx2 number;
    idx3 number;


    --this cursor will give us document_id, old path, new path for each set of path replacement strings
    CURSOR doc_cur( c_old_str VARCHAR2, c_new_str VARCHAR2) IS
        SELECT document_id,  dm_folder_path old_path, REPLACE(dm_folder_path, c_old_str, c_new_str) new_path
        FROM
          FND_DOCUMENTS
        WHERE
          dm_folder_path IS NOT NULL AND dm_node= repos_id
          AND dm_folder_path LIKE  c_old_str ||'%';

 -- this cursor takes care of folder paths with user names
    CURSOR doc_cur2( c_old_str VARCHAR2, c_new_str VARCHAR2) IS
        SELECT document_id,  dm_folder_path old_path,
        REPLACE(
            REPLACE(c_new_str, 'first.last',SUBSTR(dm_folder_path, 2, (INSTR(dm_folder_path, '-Public')-2))),
            '<f>',UPPER(SUBSTR(dm_folder_path, 2, 1))) || SubStr(dm_folder_path, InStr(dm_folder_path, '-Public')+7) new_path
        FROM
          FND_DOCUMENTS
        WHERE
          dm_folder_path IS NOT NULL
          AND dm_node= repos_id
          AND dm_folder_path LIKE   '/%-Public%'
          AND NOT dm_folder_path LIKE '/%/%-Public%'
    union
    SELECT document_id,  dm_folder_path old_path,
        REPLACE(
            REPLACE(c_new_str, 'first.last', SUBSTR(dm_folder_path, Length('/AllPublic/Users/Users-_/')+1, (INSTR(dm_folder_path, '-Public')-(Length('/AllPublic/Users/Users-_/')+1)))),
            '<f>',
            UPPER(SUBSTR(dm_folder_path, Length('/AllPublic/Users/Users-_/')+1, 1))
        )|| SubStr(dm_folder_path, InStr(dm_folder_path, '-Public')+7)  new_path
        FROM
          FND_DOCUMENTS
        WHERE
          dm_folder_path IS NOT NULL
          AND dm_node= repos_id
          AND dm_folder_path LIKE   '/AllPublic/Users/Users-_/%-Public%'  ;


    CURSOR doc_cur3(c_old_str VARCHAR2, c_new_str VARCHAR2 ) IS
        SELECT doc.document_id,  doc.dm_folder_path old_path,
        REPLACE(dm_folder_path,c_old_str, c_new_str )||'/'||REPLACE(tl.file_name,'-Public','') new_path
        from
            fnd_documents  doc,
            fnd_documents_tl tl
        where
          doc.document_id = tl.document_id
          AND dm_node = repos_id
          AND tl.LANGUAGE ='US'
          AND (dm_folder_path like c_old_str OR dm_folder_path like '/AllPublic/Users/Users-_')
          AND tl.file_name LIKE '%-Public'
        union
         SELECT document_id,  dm_folder_path old_path,
              REPLACE(
              dm_folder_path,
                (c_old_str ||
                (SUBSTR(dm_folder_path, Length(c_old_str)+1,(InStr(SUBSTR(dm_folder_path, Length(c_old_str)),'-Public') -2)))||'-Public'
                ),
               (c_new_str ||
                (SUBSTR(dm_folder_path, Length(c_old_str)+1,(InStr(SUBSTR(dm_folder_path, Length(c_old_str)),'-Public') -2)))
                ||(SUBSTR(dm_folder_path, Length(c_old_str)+1,(InStr(SUBSTR(dm_folder_path, Length(c_old_str)),'-Public') -2)))||'-Public'
               )
                ) new_path
        from
            fnd_documents
        where
          dm_node = repos_id
          AND dm_folder_path like c_old_str||'%-Public%'
          AND not dm_folder_path like c_old_str||'/%/%-Public%' ;

    CURSOR doc_cur4(c_old_str VARCHAR2, c_new_str VARCHAR2 ) IS
        SELECT doc.document_id,  doc.dm_folder_path old_path, REPLACE(dm_folder_path,c_old_str, c_new_str ) new_path, tl.file_name file_name
        from
            fnd_documents  doc,
            fnd_documents_tl tl
        where
          doc.document_id = tl.document_id
          AND dm_node = repos_id
          AND tl.LANGUAGE ='US'
          AND tl.file_name in ('Workspaces' ,'SharedFolders')
          AND doc.dm_folder_path = c_old_str  ;
    --end of declaration section

    BEGIN
          --  newline_char := '\n' ;
           select fnd_global.local_chr(10) into newline_char from dual ;

           SELECT id, DAV_URL, SERVICE_URL INTO repos_id,old_dav_url, old_service_url FROM dom_repositories WHERE short_name = p_short_name ;
           x_msg := newline_char || newline_char ||' ######## Repository ID:' || repos_id ;

          --updating dav_url
           select INSTR(old_dav_url, '/files/content') , INSTR(old_dav_url, '/content') , INSTR(old_dav_url, '/content/dav')  into idx1, idx2, idx3   from dual ;

           if(idx1 > 1 and  idx3 = 0 ) THEN
                UPDATE dom_repositories SET
                    DAV_URL = REPLACE(DAV_URL,'files/content','content/dav')
                WHERE id = repos_id ;

           elsif(idx2 > 1 and  idx3 = 0 ) THEN
                UPDATE dom_repositories SET
                    DAV_URL = REPLACE(DAV_URL,'content','content/dav')
                WHERE id = repos_id ;
        end if ;
        --updating service_url
            select INSTR(old_service_url, '/files/app') , INSTR(old_service_url, '/app') , INSTR(old_service_url, '/content/app')  into idx1, idx2, idx3   from dual ;
           if(idx1 > 1 and  idx3 = 0 ) THEN
                UPDATE dom_repositories SET
                    SERVICE_URL = REPLACE(SERVICE_URL,'files/app','content/app')
                WHERE id = repos_id ;

           elsif(idx2 > 1 and  idx3 = 0 ) THEN
                UPDATE dom_repositories SET
                    SERVICE_URL = REPLACE(SERVICE_URL,'app','content/app')
                WHERE id = repos_id ;
        end if ;

        IF(p_old_str IS NOT NULL) THEN
                    x_msg :=  x_msg ||newline_char || p_old_str || '  -- '|| p_new_str;
                 SELECT REPLACE(p_new_str , 'DomainName', p_domain ) into p_new_str FROM dual ;

                 IF(p_old_str = '/AllPublic' ) THEN
                    x_msg :=  x_msg ||newline_char || 'cursor 4' ;
                    FOR l_row IN  doc_cur4(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;
                        UPDATE fnd_documents SET  dm_folder_path = new_path
                        WHERE document_id = doc_id ;
                        --updating eng_attachment_changes
                        UPDATE ENG_ATTACHMENT_CHANGES SET source_path = new_path , FILE_NAME = 'Libraries'
                        WHERE SOURCE_DOCUMENT_ID = doc_id ;

                        --changing file name
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '   changing file_name  for language code US, from '|| l_row.file_name || ' to Libraries '  ;
                        UPDATE fnd_documents_tl SET  file_name = 'Libraries'
                        WHERE document_id = doc_id ;

                     END LOOP;
                 End IF;

                 IF(p_old_str = '/AllPublic/Workspaces' or p_old_str = '/AllPublic/SharedFolders' ) THEN
                    x_msg :=  x_msg ||newline_char || 'cursor 3' ;
                    FOR l_row IN  doc_cur3(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;
                        UPDATE fnd_documents SET  dm_folder_path = new_path
                        WHERE document_id = doc_id ;
                        --updating eng_attachment_changes
                        UPDATE ENG_ATTACHMENT_CHANGES SET source_path = new_path
                        WHERE SOURCE_DOCUMENT_ID = doc_id ;

                     END LOOP;

                 ELSIF( INSTR(p_old_str,'.') >0 ) THEN
                    x_msg :=  x_msg ||newline_char || 'cursor 2' ;
                    FOR l_row IN  doc_cur2(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;
                        UPDATE fnd_documents SET  dm_folder_path = new_path
                        WHERE document_id = doc_id ;
                        --updating eng_attachment_changes
                        UPDATE ENG_ATTACHMENT_CHANGES SET source_path = new_path
                        WHERE SOURCE_DOCUMENT_ID = doc_id ;
                     END LOOP;

                ELSE
                    x_msg :=  x_msg ||newline_char || 'cursor 1' ;
                     FOR l_row IN  doc_cur(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;
                        UPDATE fnd_documents SET  dm_folder_path = new_path
                        WHERE document_id = doc_id ;
                        --updating eng_attachment_changes
                        UPDATE ENG_ATTACHMENT_CHANGES SET source_path = new_path
                        WHERE SOURCE_DOCUMENT_ID = doc_id ;
                     END LOOP;
                END IF;
        END IF;
            x_msg := x_msg || newline_char || '*** Folder path updated successfully  for path : ' || p_old_str || ' -> '|| p_new_str || '  ***' ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
              x_msg := x_msg || newline_char ||  '*** Script failed : Invalid repository short name ***' ;
              x_msg := x_msg || newline_char || 'RollBack Done' ;
              rollback;
        WHEN OTHERS THEN
          x_msg := x_msg || newline_char || newline_char ||' *** Script failed with error error is :' || SQLERRM || '***';
          x_msg := x_msg || newline_char || 'RollBack Done' ;
          rollback;
    END;



PROCEDURE GET_NEW_PATH (
  p_short_name IN VARCHAR2,
  p_domain IN VARCHAR2,
  p_old_str IN varchar2,
  p_new_str IN OUT NOCOPY varchar2,
  p_doc_id IN Number,
  x_msg IN OUT NOCOPY varchar2
  --p_isNewTable IN NUMBER
) IS
    --str_count NUMBER ;
    doc_id NUMBER;
    old_path VARCHAR2(1000);
    new_path VARCHAR2(1000);
    repos_id NUMBER ;
    dot_index NUMBER ;    --used to check if old string is of type firs.last
    newline_char VARCHAR2(2) ;
    old_dav_url varchar2(240);
    old_service_url varchar2(240);
    idx1 number;
    idx2 number;
    idx3 number;


    --this cursor will give us document_id, old path, new path for each set of path replacement strings
    CURSOR doc_cur( c_old_str VARCHAR2, c_new_str VARCHAR2) IS
        SELECT document_id,  dm_folder_path old_path, REPLACE(dm_folder_path, c_old_str, c_new_str) new_path
        FROM
          FND_DOCUMENTS
        WHERE
          dm_folder_path IS NOT NULL AND dm_node= repos_id
          AND dm_folder_path LIKE  c_old_str ||'%'
          AND document_id = p_doc_id ;

 -- this cursor takes care of folder paths with user names
    CURSOR doc_cur2( c_old_str VARCHAR2, c_new_str VARCHAR2) IS
        SELECT document_id,  dm_folder_path old_path,
        REPLACE(
            REPLACE(c_new_str, 'first.last',SUBSTR(dm_folder_path, 2, (INSTR(dm_folder_path, '-Public')-2))),
            '<f>',UPPER(SUBSTR(dm_folder_path, 2, 1))) || SubStr(dm_folder_path, InStr(dm_folder_path, '-Public')+7) new_path
        FROM
          FND_DOCUMENTS
        WHERE
          dm_folder_path IS NOT NULL
          AND dm_node= repos_id
          AND dm_folder_path LIKE   '/%-Public%'
          AND NOT dm_folder_path LIKE '/%/%-Public%'
          AND document_id = p_doc_id
    union
    SELECT document_id,  dm_folder_path old_path,
        REPLACE(
            REPLACE(c_new_str, 'first.last', SUBSTR(dm_folder_path, Length('/AllPublic/Users/Users-_/')+1, (INSTR(dm_folder_path, '-Public')-(Length('/AllPublic/Users/Users-_/')+1)))),
            '<f>',
            UPPER(SUBSTR(dm_folder_path, Length('/AllPublic/Users/Users-_/')+1, 1))
        )|| SubStr(dm_folder_path, InStr(dm_folder_path, '-Public')+7)  new_path
        FROM
          FND_DOCUMENTS
        WHERE
          dm_folder_path IS NOT NULL
          AND dm_node= repos_id
          AND dm_folder_path LIKE   '/AllPublic/Users/Users-_/%-Public%'
          AND document_id = p_doc_id ;


    CURSOR doc_cur3(c_old_str VARCHAR2, c_new_str VARCHAR2 ) IS
        SELECT doc.document_id,  doc.dm_folder_path old_path,
        REPLACE(dm_folder_path,c_old_str, c_new_str )||'/'||REPLACE(tl.file_name,'-Public','') new_path
        from
            fnd_documents  doc,
            fnd_documents_tl tl
        where
          doc.document_id = tl.document_id
          AND dm_node = repos_id
          AND tl.LANGUAGE ='US'
          AND (dm_folder_path like c_old_str OR dm_folder_path like '/AllPublic/Users/Users-_')
          AND tl.file_name LIKE '%-Public'
          AND doc.document_id = p_doc_id
        union
         SELECT document_id,  dm_folder_path old_path,
              REPLACE(
              dm_folder_path,
                (c_old_str ||
                (SUBSTR(dm_folder_path, Length(c_old_str)+1,(InStr(SUBSTR(dm_folder_path, Length(c_old_str)),'-Public') -2)))||'-Public'
                ),
               (c_new_str ||
                (SUBSTR(dm_folder_path, Length(c_old_str)+1,(InStr(SUBSTR(dm_folder_path, Length(c_old_str)),'-Public') -2)))
                ||(SUBSTR(dm_folder_path, Length(c_old_str)+1,(InStr(SUBSTR(dm_folder_path, Length(c_old_str)),'-Public') -2)))||'-Public'
               )
                ) new_path
        from
            fnd_documents
        where
          dm_node = repos_id
          AND dm_folder_path like c_old_str||'%-Public%'
          AND not dm_folder_path like c_old_str||'/%/%-Public%'
          AND document_id = p_doc_id ;

    CURSOR doc_cur4(c_old_str VARCHAR2, c_new_str VARCHAR2 ) IS
        SELECT doc.document_id,  doc.dm_folder_path old_path, REPLACE(dm_folder_path,c_old_str, c_new_str ) new_path, tl.file_name file_name
        from
            fnd_documents  doc,
            fnd_documents_tl tl
        where
          doc.document_id = tl.document_id
          AND dm_node = repos_id
          AND tl.LANGUAGE ='US'
          AND tl.file_name in ('Workspaces' ,'SharedFolders')
          AND doc.dm_folder_path = c_old_str
          AND doc.document_id = p_doc_id ;
    --end of declaration section

    BEGIN
          --  newline_char := '\n' ;
           select fnd_global.local_chr(10) into newline_char from dual ;

           SELECT id, DAV_URL, SERVICE_URL INTO repos_id,old_dav_url, old_service_url FROM dom_repositories WHERE short_name = p_short_name ;
           x_msg := newline_char || newline_char ||' ######## Repository ID:' || repos_id ;


        IF(p_old_str IS NOT NULL) THEN
                    x_msg :=  x_msg ||newline_char || p_old_str || '  -- '|| p_new_str;
                 SELECT REPLACE(p_new_str , 'DomainName', p_domain ) into p_new_str FROM dual ;

                 IF(p_old_str = '/AllPublic' ) THEN
                    x_msg :=  x_msg ||newline_char || 'cursor 4' ;
                    FOR l_row IN  doc_cur4(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;

                        --changing file name
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '   changing file_name  for language code US, from '|| l_row.file_name || ' to Libraries '  ;

                     END LOOP;
                 End IF;

                 IF(p_old_str = '/AllPublic/Workspaces' or p_old_str = '/AllPublic/SharedFolders' ) THEN
                    x_msg :=  x_msg ||newline_char || 'cursor 3' ;
                    FOR l_row IN  doc_cur3(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;
                     END LOOP;

                 ELSIF( INSTR(p_old_str,'.') >0 ) THEN
                    x_msg :=  x_msg ||newline_char || 'cursor 2' ;
                    FOR l_row IN  doc_cur2(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;
                     END LOOP;

                ELSE
                    x_msg :=  x_msg ||newline_char || 'cursor 1' ;
                     FOR l_row IN  doc_cur(p_old_str, p_new_str)
                     LOOP
                        doc_id := l_row.document_id ;
                        old_path:= l_row.old_path ;
                        new_path:= l_row.new_path ;
                        x_msg := x_msg || newline_char || 'DocID :' || doc_id || '-  ' || old_path || ' -> ' || new_path ;
                     END LOOP;
                END IF;
        END IF;
        x_msg := new_path ;
            --x_msg := x_msg || newline_char || '*** Folder path updated successfully  for path : ' || p_old_str || ' -> '|| p_new_str || '  ***' ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
              x_msg := 'NO_DATA_FOUND' ;
              rollback;
        WHEN OTHERS THEN
          x_msg := x_msg || newline_char || newline_char ||' *** Script failed with error error is :' || SQLERRM || '***';
          rollback;
    END;

END DOM_REPOS_MIG_PKG;

/
