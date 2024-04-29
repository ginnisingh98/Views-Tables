--------------------------------------------------------
--  DDL for Package Body FND_TXK_TECH_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TXK_TECH_INT_PKG" AS
/* $Header: fndtxk01b.pls 120.0.12010000.3 2009/09/07 21:09:54 upinjark noship $*/


FUNCTION store_into_fnd_preference (p_file_id NUMBER)
RETURN NUMBER
IS
  /*
  ||  Created By : upinjark
  ||  Created On : 17-Jun-2009
  ||  Purpose :        Stores bpel preference.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

BEGIN

  fnd_preference.put('#INTERNAL', 'BPEL_INT', 'TXK_BPEL_FILE_ID_' || p_file_id, 'EbsBpelGlobal.properties') ;
  RETURN 1 ;

EXCEPTION
  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, SQLERRM);
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('NAME','FND_TXK_TECH_INT_PKG.store_into_fnd_preference');
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     RETURN(NULL);
END store_into_fnd_preference;

FUNCTION store_into_fnd_lob(p_args_table IN FND_TXK_BPEL_ARGS_TYPE )
RETURN NUMBER
IS
  /*
  ||  Created By : upinjark
  ||  Created On : 17-Jun-2009
  ||  Purpose :    stores the bpel parameters in fnd_lobs
  ||  Known limitations, enhancements or remarks :
  ||
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   l_file_id NUMBER;
   mime_type VARCHAR2(200);
   l_loop_counter NUMBER;
   args_count NUMBER ;

BEGIN

  l_loop_counter := 0;
  args_count := 0 ;

  mime_type := NVL(fnd_profile.value('FND_EXPORT_MIME_TYPE'), 'text/tab-separated-values');
  l_file_id := fnd_gfm.file_create(content_type => mime_type,
                                 file_name => 'EbsBpelGlobal.properties' ,
                                 program_name => 'BPEL Integration');

     FOR i IN p_args_table.FIRST .. p_args_table.LAST
     LOOP
	fnd_gfm.file_write_line(l_file_id, p_args_table(i));
     END LOOP;

  l_file_id := fnd_gfm.file_close(l_file_id);

  RETURN (l_file_id);

EXCEPTION
  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, SQLERRM);
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('NAME','FND_TXK_TECH_INT_PKG.store_into_fnd_lob');

     RETURN(NULL);
END store_into_fnd_lob;


FUNCTION remove_bpel_info_if_exists
RETURN NUMBER
IS
/*
||  Created By : upinjark
||  Created On : 17-JUN-2009
||  Purpose : TO remove bpel info from fnd_lobs and fnd_preference
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  l_bpel_count      NUMBER;
  l_old_file_id     VARCHAR2(32);
  l_retcode        NUMBER;

BEGIN

   l_retcode            := 0;
   l_old_file_id        := NULL;
   l_bpel_count         := 0;


   -- find out from fnd_preference if any fnd_preference exists ....
   -- if fnd_preference exist, get the file ids

     BEGIN
       select substr(preference_name,18) into l_old_file_id
       from fnd_user_preferences
       where PREFERENCE_NAME like 'TXK_BPEL_FILE_ID_%'
       and PREFERENCE_VALUE = 'EbsBpelGlobal.properties'
       and USER_NAME = '#INTERNAL' ;

      if l_old_file_id is not null then
        -- delete fnd_lob rows for the file id and file_name = EbsBpelGlobal.properties ...
        delete from fnd_lobs where file_id = l_old_file_id;
        -- delete fnd_preference rows for
        fnd_preference.remove('#INTERNAL', 'BPEL_INT', 'TXK_BPEL_FILE_ID_'|| l_old_file_id );
      end if;

     EXCEPTION
       when no_data_found then null;
     END;

   return l_retcode;

EXCEPTION
   WHEN others THEN
        ROLLBACK;
        l_retcode := 2;
        fnd_file.put_line(fnd_file.log, SQLERRM);

        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('NAME','FND_TXK_TECH_INT_PKG.remove_bpel_info_if_exists');
        fnd_message.set_token('ERRNO', SQLCODE);
	return l_retcode;
END  remove_bpel_info_if_exists;


PROCEDURE store_bpel_info ( errbuf            OUT NOCOPY VARCHAR2,
                            retcode           OUT NOCOPY NUMBER,
                            p_args_table      IN  FND_TXK_BPEL_ARGS_TYPE
                          )
IS

/*
||  Created By : upinjark
||  Created On : 17-JUN-2009
||  Purpose : Main process which in turn calls fnd_lob and fnd_preference
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  l_file_id       NUMBER;
  old_file_id     VARCHAR2(32);

BEGIN
   errbuf             := NULL;
   retcode            := 0;
   old_file_id        := NULL;

   retcode := remove_bpel_info_if_exists ;

   l_file_id := store_into_fnd_lob(p_args_table);
   retcode := store_into_fnd_preference(l_file_id);

   -- COMMIT;

EXCEPTION
   WHEN others THEN
        ROLLBACK;
        retcode := 2;
        fnd_file.put_line(fnd_file.log, SQLERRM);

        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('NAME','FND_TXK_TECH_INT_PKG.store_bpel_info');
        fnd_message.set_token('ERRNO', SQLCODE);
        errbuf  := fnd_message.get;
END  store_bpel_info;

END FND_TXK_TECH_INT_PKG;

/
