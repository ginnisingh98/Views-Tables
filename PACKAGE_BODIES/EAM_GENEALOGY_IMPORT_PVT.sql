--------------------------------------------------------
--  DDL for Package Body EAM_GENEALOGY_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_GENEALOGY_IMPORT_PVT" as
/* $Header: EAMVGEIB.pls 120.2 2006/07/11 13:31:48 kmurthy noship $*/

   -- Start of comments
   -- API name : Load_Genealogy
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters :
   -- IN       p_batch_id         IN      NUMBER Required,
   --          p_purge_option     IN      VARCHAR2 Optional Default = 'N'
   -- OUT      ERRBUF OUT VARCHAR2,
   --          RETCODE OUT VARCHAR2
   --
   -- Version  Initial version    1.0     Kenichi Nagumo
   --
   -- Notes    : This public API imports asset genealogy into
   --            MTL_OBJECT_GENEALOGY
   --
   -- End of comments

   -- global variable to turn on/off debug logging.
   G_DEBUG VARCHAR2(1) := NVL(fnd_profile.value('EAM_DEBUG'), 'N');

PROCEDURE Load_Genealogy
    (ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY VARCHAR2,
     p_batch_id IN NUMBER,
     p_purge_option IN VARCHAR2 := 'N'
     ) IS

    l_retcode Number;
    CONC_STATUS BOOLEAN;

BEGIN

        l_retcode := import_genealogy(p_batch_id, p_purge_option);

        if l_retcode = 1 then
                IF G_DEBUG = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG, 'Completed Successfully.');
                  fnd_file.put_line(FND_FILE.LOG, Current_Error_Code);
                END IF;
                RETCODE := 'Success';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);
        elsif l_retcode = 3 then
                IF G_DEBUG = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG, 'Completed with Warning.');
                  fnd_file.put_line(FND_FILE.LOG, Current_Error_Code);
                END IF;
                RETCODE := 'Warning';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);
        else
                IF G_DEBUG = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG, 'Completed with Error.');
                  fnd_file.put_line(FND_FILE.LOG, Current_Error_Code);
                END IF;
                RETCODE := 'Error';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
        end if;

END Load_Genealogy;


PROCEDURE Launch_Worker
  (
    p_group_id                NUMBER,
    p_batch_id                NUMBER,
    p_purge_option            VARCHAR2,
    p_count                   NUMBER
  ) IS
    l_request_id              NUMBER  := 0;
BEGIN

 IF G_DEBUG = 'Y' THEN
   fnd_file.put_line(FND_FILE.LOG, 'Submitting Import Worker '||p_group_id
    || ' to process ' || p_count || ' genealogy');
 END IF;

 COMMIT;

  l_request_id := FND_REQUEST.submit_request(
                              'EAM',
                              'EAMGEIMW',
                              NULL,
                              NULL,
                              FALSE,
                              p_group_id,
                              p_purge_option
                              );

   IF (l_request_id = 0 OR l_request_id IS NULL) then
      -- failed to launch the process
      UPDATE  mtl_object_genealogy_interface mogi
      SET     mogi.error_code = 9999,
              mogi.process_status = 'E',
              mogi.error_message = 'Failed to submit worker for Group ID = '||p_group_id
      WHERE   mogi.process_status = 'P'
      AND     mogi.batch_id = p_batch_id
      AND     mogi.group_id = p_group_id;
      COMMIT;

      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, 'Failed to Launch the Process.');
        fnd_file.new_line(FND_FILE.LOG,1);
      END IF;

      RAISE fnd_api.g_exc_error;
   ELSE
      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, 'Import Worker '||p_group_id||' successfully submitted.');
        fnd_file.new_line(FND_FILE.LOG,1);
      END IF;
   END IF;
END Launch_Worker;




FUNCTION Import_Genealogy
    (
    p_batch_id           IN   NUMBER,
    p_purge_option       IN   VARCHAR2       := 'N'
    )  RETURN Number IS

    l_max_rows_to_process     NUMBER         := 500;
    l_counter                 NUMBER         := 0;
    l_num_genealogy           NUMBER         := 0;
    l_num_workers             NUMBER         := 0;
    l_num_genealogy_to_workers NUMBER         := 0;
    error_number              NUMBER         := NULL;
    error_message             VARCHAR2(2000) := NULL;
    error_counter             NUMBER         := 0;
    curr_error                VARCHAR2(9)    := 'APP-00000';

    l_group_id                NUMBER         := 0;
    l_success                 NUMBER         := 1;

    CURSOR genealogy_rows_cur IS
        SELECT
                mogi.organization_id,
                mogi.inventory_item_id,
                mogi.serial_number,
                count(*) as total
        FROM    mtl_object_genealogy_interface mogi
        WHERE   mogi.batch_id = p_batch_id
        AND     mogi.group_id IS NULL
        AND     mogi.process_status = 'P'
        AND     mogi.error_code IS NULL
        AND     mogi.error_message IS NULL
        GROUP BY
                mogi.organization_id,
                mogi.inventory_item_id,
                mogi.serial_number
        ORDER BY
                mogi.organization_id,
                mogi.inventory_item_id,
                mogi.serial_number;

    BEGIN

    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'Batch Id = '||p_batch_id);
      fnd_file.put_line(FND_FILE.LOG,'Purge Option = '||p_purge_option);
      fnd_file.put_line(FND_FILE.LOG,'Max Rows to process = '||l_max_rows_to_process);
      fnd_file.new_line(FND_FILE.LOG, 1);
    END IF;


      -- Validate Mode Values:
      -- 0: Create
      -- 1: Update

      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'Validating Mode Values.');
      END IF;

      UPDATE    mtl_object_genealogy_interface mogi
      SET       mogi.process_status = 'E',
                mogi.error_code = 9999,
                mogi.error_message = 'Incorrect Mode Value'
      WHERE     mogi.batch_id = p_batch_id
      AND       mogi.import_mode NOT IN (0,1)
      AND       mogi.process_status = 'P';


 -- validate that the genealogy origin of all entries is 3
    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,  'Validating Genealogy Origin');
    END IF;

    UPDATE MTL_OBJECT_GENEALOGY_INTERFACE
    SET process_status = 'E',
    error_code = 9999,
    error_message = 'Incorrent Genealogy Origin'
    WHERE batch_id = p_batch_id
    and   genealogy_origin <> 3
    and   process_status = 'P';

 -- validate that the object type of all entries is 2
    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'Validating Object Type');
    END IF;

    UPDATE MTL_OBJECT_GENEALOGY_INTERFACE
    SET process_status = 'E',
    error_code = 9999,
    error_message = 'Incorrent Object Type'
    WHERE batch_id = p_batch_id
    and   (object_type <> 2
    or    parent_object_type <> 2)
    and   process_status = 'P';

    COMMIT;

 -- validate that the genealogy type of all entries is 5
    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'Validating Genealogy Type');
    END IF;

    UPDATE MTL_OBJECT_GENEALOGY_INTERFACE
    SET process_status = 'E',
    error_code = 9999,
    error_message = 'Incorrent Genealogy Type'
    WHERE batch_id = p_batch_id
    and   genealogy_type <> 5
    and   process_status = 'P';

    COMMIT;

      -- Validate Organization Code:
      -- Organization and Parent Organization have to be the same.

    UPDATE    mtl_object_genealogy_interface mogi
    SET       process_status = 'E' , error_code = 9999, error_message = 'Invalid Organization. Organization and Parent Organization have to be the same.'
    WHERE     batch_id = p_batch_id
    AND       ( select mp.maint_organization_id from mtl_parameters mp
               where mp.organization_code = mogi.organization_code )
	       <>
	      ( select mp.maint_organization_id from mtl_parameters mp
               where mp.organization_code = mogi.parent_organization_code )
    AND       process_status = 'P';

    COMMIT;

      -- Validate Organization Code:
      -- If both organization_code and organization_id is provided, organization_id will be used.

      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'Validating Organization Code.');
        fnd_file.new_line(FND_FILE.LOG,1);
      END IF;


    UPDATE    mtl_object_genealogy_interface mogi
    SET       organization_code= (select organization_code from mtl_parameters
               where organization_id = mogi.organization_id
	       and maint_organization_id is not null)
    WHERE     batch_id = p_batch_id
    AND       organization_id is not null
    AND       process_status = 'P';

    UPDATE   mtl_object_genealogy_interface mogi
    SET       organization_id= (select organization_id from mtl_parameters
               where organization_code = mogi.organization_code
       	       and maint_organization_id is not null)
    WHERE     batch_id = p_batch_id
    AND       organization_id is null
    AND       organization_code is not null
    AND       process_status = 'P';

    UPDATE    mtl_object_genealogy_interface mogi
    SET       process_status = 'E' , error_code = 9999, error_message = 'Invalid Organization. Check that it is NOT NULL, EXISTS and is EAM ENABLED'
    WHERE     batch_id = p_batch_id
    AND       (organization_id is null
               OR  organization_code is null)
    AND       process_status = 'P';

    COMMIT;

      -- Validate Parent Organization Code:
      -- If both organization_code and organization_id is provided, organization_id will be used.

      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'Validating Parent Organization Code.');
        fnd_file.new_line(FND_FILE.LOG,1);
      END IF;

    UPDATE    mtl_object_genealogy_interface mogi
    SET       parent_organization_code= (select organization_code from mtl_parameters
               where organization_id = mogi.parent_organization_id
	       and maint_organization_id is not null)
    WHERE     batch_id = p_batch_id
    AND       parent_organization_id is not null
    AND       process_status = 'P';

    UPDATE   mtl_object_genealogy_interface mogi
    SET       parent_organization_id= (select organization_id from mtl_parameters
               where organization_code = mogi.parent_organization_code
	       and maint_organization_id is not null)
    WHERE     batch_id = p_batch_id
    AND       parent_organization_id is null
    AND       parent_organization_code is not null
    AND       process_status = 'P';

    UPDATE    mtl_object_genealogy_interface mogi
    SET       process_status = 'E' , error_code = 9999, error_message = 'Invalid Parent Organization. Check that it is NOT NULL, EXISTS and is EAM ENABLED'
    WHERE     batch_id = p_batch_id
    AND       (parent_organization_id is null
               OR  parent_organization_code is null)
    AND       process_status = 'P';

    COMMIT;


      -- Validate Parent Organization Code:
      -- If both organization_code and organization_id is provided, organization_id will be used.

      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'Validating Parent Organization Id.');
        fnd_file.new_line(FND_FILE.LOG,1);
      END IF;

    UPDATE    mtl_object_genealogy_interface mogi
    SET       object_id = (select gen_object_id from mtl_serial_numbers
               where current_organization_id = mogi.organization_id
               and   inventory_item_id = mogi.inventory_item_id
               and   serial_number = mogi.serial_number)
    WHERE     batch_id = p_batch_id
    AND       process_status = 'P';

    UPDATE    mtl_object_genealogy_interface mogi
    SET       parent_object_id = (select gen_object_id from mtl_serial_numbers
               where current_organization_id = mogi.parent_organization_id
               and   inventory_item_id = mogi.parent_inventory_item_id
               and   serial_number = mogi.parent_serial_number)
    WHERE     batch_id = p_batch_id
    AND       process_status = 'P';

    UPDATE    mtl_object_genealogy_interface mogi
    SET       process_status = 'E' , error_code = 9999, error_message = 'Invalid Serial Number. Check that it exists in the organization.'
    WHERE     batch_id = p_batch_id
    AND       (object_id is null
               OR  parent_object_id is null)
    AND       process_status = 'P';


    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Start record pre-processing. Time now is ' ||
      to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
    END IF;

    FOR genealogy IN genealogy_rows_cur
    LOOP

           --get a group id for worker
      if (l_counter = 0) then
        SELECT MTL_OBJECT_GEN_INTERFACE_S.nextval
        INTO  l_group_id
        FROM  dual;
      end if;

           --have to update after each record ...
    UPDATE  mtl_object_genealogy_interface mogi
    SET     mogi.group_id = l_group_id,
            mogi.process_status = 'R'
    WHERE   mogi.process_status = 'P'
    AND     mogi.organization_id = genealogy.organization_id
    AND     mogi.inventory_item_id = genealogy.inventory_item_id
    AND     mogi.serial_number = genealogy.serial_number
    AND     mogi.batch_id = p_batch_id
    AND     mogi.group_id IS NULL;

      l_counter := l_counter + genealogy.total;
      l_num_genealogy := l_num_genealogy + genealogy.total;

      IF (l_counter > l_max_rows_to_process) THEN
           Launch_Worker(l_group_id, p_batch_id, p_purge_option, l_counter);
           l_num_genealogy_to_workers := l_num_genealogy_to_workers + l_counter;
           l_counter := 0;
           l_num_workers := l_num_workers + 1;
      END IF;

    END LOOP;

      if (l_num_genealogy > l_num_genealogy_to_workers) then -- we still have more to process
      Launch_Worker(l_group_id, p_batch_id, p_purge_option, l_counter);
      l_num_genealogy_to_workers := l_num_genealogy_to_workers + l_counter;
      l_num_workers := l_num_workers + 1;
      end if;

    IF G_DEBUG = 'Y' THEN
      fnd_file.new_line(FND_FILE.LOG,1);

      fnd_file.put_line(FND_FILE.LOG, 'Stop record pre-processing. Time now is ' ||
      to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
      fnd_file.new_line(FND_FILE.LOG,1);
    END IF;

    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, l_num_workers ||' Import Workers are processing '
      ||l_num_genealogy_to_workers || ' Genealogy');
    END IF;

    if not (l_num_genealogy_to_workers = l_num_genealogy) then
      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, 'WARNING: There is a discrepancy. Total Genealogy ('
        || l_num_genealogy || ') does not match total given to workers ('
        || l_num_genealogy_to_workers || ')');
        fnd_file.new_line(FND_FILE.LOG,1);

      END IF;

    end if;

    COMMIT;
    Return l_success;

EXCEPTION

        WHEN ERROR THEN

                l_success := 3;
                error_counter   :=      error_counter + 1;
                error_number    := SQLCODE;
                error_message   := SUBSTR(SQLERRM, 1, 512);

                IF G_DEBUG = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG, error_number);
                  fnd_file.put_line(FND_FILE.LOG, error_message);
                  fnd_file.new_line(FND_FILE.LOG,1);
                END IF;


                COMMIT;
                Return l_success;

        WHEN OTHERS THEN

                l_success := 2;
                error_counter   := error_counter + 1;
                error_number    := SQLCODE;
                error_message   := SUBSTR(SQLERRM, 1, 512);

                IF G_DEBUG = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG, error_number);
                  fnd_file.put_line(FND_FILE.LOG, error_message);
                  fnd_file.new_line(FND_FILE.LOG,1);
                END IF;

                COMMIT;
                Return l_success;

  END Import_Genealogy;

END EAM_GENEALOGY_IMPORT_PVT;

/
