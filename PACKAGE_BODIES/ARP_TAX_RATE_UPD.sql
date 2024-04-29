--------------------------------------------------------
--  DDL for Package Body ARP_TAX_RATE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TAX_RATE_UPD" as
/* $Header: ARTAXRATEB.pls 120.1 2005/10/30 04:45:58 appldev ship $ */



PROCEDURE  update_tax_rate( errbuf        OUT NOCOPY   VARCHAR2,
                            retcode       OUT NOCOPY   VARCHAR2,
                            p_batch_size  IN NUMBER,
                            p_worker_id   IN NUMBER,
                            p_num_workers IN NUMBER  ) IS

  l_limit_rows      number ;

  l_table_owner     varchar2(30) ;
  l_batch_size      NUMBER ;
  l_worker_id       number  ;
  l_num_workers     number  ;
  l_any_rows_to_process boolean;

  l_table_name      varchar2(30);
  l_update_name     varchar2(30);

  l_start_rowid     rowid;
  l_end_rowid       rowid;
  l_rows_processed  number;

  ln_cnt            number;
BEGIN
     ln_cnt := 0;
     l_table_name      := 'RA_CUSTOMER_TRX_LINES_ALL';
     l_update_name     := 'ar3294352.sql';
     l_table_owner := 'AR';
     l_batch_size  := p_batch_size;
     l_worker_id   := p_worker_id;
     l_num_workers :=  p_num_workers;
-- Value populated if the conc. parameters are null.
     fnd_file.put_line( fnd_file.log,'l_batch_size = ' || to_char(l_batch_size));
     fnd_file.put_line( fnd_file.log,'l_worker_id = ' || to_char(l_worker_id));
     fnd_file.put_line( fnd_file.log,'l_num_workers = ' || to_char(l_num_workers));
     if l_batch_size is NULL then
      l_batch_size := 999;
     end if;
     if l_worker_id is NULL then
       l_worker_id := 2;
     end if;
     if l_num_workers is null then
       l_num_workers :=4;
     end if;

 -- Check the value in ar_system_parameters_all table and determine the work otherwise EXIT
    BEGIN
         select count(*) into ln_cnt  from ar_system_parameters_all
         where TAX_DATABASE_VIEW_SET in ('_V','_A')
         and nvl(global_attribute17,'XXXXXX')  not in ('EFF_RATE_ENH','EFF_RATE_RUN');
         fnd_file.put_line( fnd_file.log,'Running Tax Rate update program in '||ln_cnt|| ' operating units.');
      EXCEPTION
         when no_data_found then
           fnd_file.put_line( fnd_file.log,'Tax Partner Integration: Tax Rate Program has already been run for this instance.');
          ln_cnt := 0;
      END;
 --Disable U.S. Sales Tax Report program
  IF ln_cnt > 0 THEN
    IF (FND_PROGRAM.PROGRAM_EXISTS(
      program       => 'ARXSTR',
      application   => 'AR'
    ))
    THEN
      FND_PROGRAM.ENABLE_PROGRAM(
        short_name  => 'ARXSTR',
        application => 'AR',
        enabled     => 'N');
    END IF;
 -- Mark the  global_attribute17 that the Program is running...
 BEGIN
       update ar_system_parameters_all p
         set global_attribute17='EFF_RATE_RUN'
         where  TAX_DATABASE_VIEW_SET in ('_V','_A');
   EXCEPTION
      when others then
         fnd_file.put_line( fnd_file.log,'ERROR1 =='||SQLERRM);
        raise;
 END;
/* ------ Initialize the rowid ranges ------ */

  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_update_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

  /* ------ Get rowid ranges ------ */

  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);
  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   BEGIN
    update /*+ rowid(t) */ ra_customer_trx_lines_all t
        set global_attribute17 = t.tax_rate,
            tax_rate = ( select round (100 * t.extended_amount /
                   l.extended_amount,2)
              from ra_customer_trx_lines_all l
              where  l.customer_trx_line_id = t.link_to_cust_trx_line_id
               and l.line_type = 'LINE'
               and l.extended_amount <> 0),
                   last_update_date = to_date(sysdate, 'DD/MM/YYYY'),
                 last_updated_by = 1
      where t.line_type = 'TAX'
        and t.global_attribute17 is null
        and t.global_attribute_category in ('VERTEX', 'AVP')
        and t.rowid between l_start_rowid and l_end_rowid;

         l_rows_processed := SQL%ROWCOUNT;
         fnd_file.put_line( fnd_file.log,'Row processed =='||l_rows_processed);
   EXCEPTION
      when others then
         fnd_file.put_line( fnd_file.log,'ERROR2 =='||SQLERRM);
        raise;
   END;

    ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

      COMMIT;

    l_rows_processed := 0 ;

    /*  get new range of rowids  */

    ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

    COMMIT;

  END LOOP ; /* end of WHILE loop */
         --Update the global_attribute17 of ar_system_parameters_all table
        begin
           update ar_system_parameters_all set global_attribute17='EFF_RATE_ENH'
            where  TAX_DATABASE_VIEW_SET in ('_V','_A')
            and global_attribute17 = 'EFF_RATE_RUN';
        exception
             when others then
             fnd_file.put_line( fnd_file.log,'ERROR3 =='||SQLERRM);
              raise;
        end;
   -- Enable US Sales tax Report program
   --Enable U.S. Sales Tax Report after completing all the tasks
    IF (FND_PROGRAM.PROGRAM_EXISTS(
      program       => 'ARXSTR',
      application   => 'AR'
    ))
    THEN
      FND_PROGRAM.ENABLE_PROGRAM(
        short_name  => 'ARXSTR',
        application => 'AR',
        enabled     => 'Y');
    END IF;
  END IF;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     ROLLBACK WORK;
     RAISE;
   WHEN OTHERS THEN
     ROLLBACK WORK;
     RAISE;

END update_tax_rate;

Procedure Master_Conc_Parallel_Upgrade(
                                       errbuf    OUT NOCOPY   VARCHAR2,
                                       retcode    OUT NOCOPY   VARCHAR2,
--                                     p_worker_conc_appsshortname IN VARCHAR2,
--                                     p_worker_conc_program IN VARCHAR2,
                                       p_batch_commit_size IN NUMBER,
                                       p_num_workers IN NUMBER) IS


l_worker_conc_appsshortname  varchar2(2);
l_worker_conc_program        varchar2(200);
l_batch_commit_size         number;
l_batch_size                NUMBER;
l_num_workers               number;
l_request_id NUMBER;

BEGIN
    l_worker_conc_appsshortname := 'AR';
    l_worker_conc_program       := 'ARTAXRATE';
    l_batch_commit_size         := p_batch_commit_size;
    l_num_workers               := p_num_workers;


    fnd_file.put_line( fnd_file.log,'l_batch_commit_size =='||to_char(l_batch_commit_size));
    fnd_file.put_line( fnd_file.log,'l_num_workers =='||to_char(l_num_workers));

   AD_CONC_UTILS_PKG.submit_subrequests(
        X_errbuf                    => errbuf,
        X_retcode                   => retcode,
        X_WorkerConc_app_shortname  => l_worker_conc_appsshortname,
        X_WorkerConc_progname       => l_worker_conc_program,
        X_Batch_Size                => l_batch_commit_size,
        X_Num_Workers               => l_num_workers,
        X_Argument4                 => NULL,
        X_Argument5                 => NULL,
        X_Argument6                 => NULL,
        X_Argument7                 => NULL,
        X_Argument8                 => NULL,
        X_Argument9                 => NULL,
       X_Argument10                => NULL);

exception
 when others then
   fnd_file.put_line( fnd_file.log,'ERROR == '||sqlerrm);
END Master_Conc_Parallel_Upgrade;

end ARP_TAX_RATE_UPD;

/
