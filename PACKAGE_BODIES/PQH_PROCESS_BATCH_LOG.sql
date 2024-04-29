--------------------------------------------------------
--  DDL for Package Body PQH_PROCESS_BATCH_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PROCESS_BATCH_LOG" AS
/* $Header: pqerrlog.pkb 115.8 2004/06/15 13:51:55 rthiagar noship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_process_batch_log.';  -- Global package name
--

--
    /*----------------------------------------------------------------
    ||
    ||                   PROCEDURE : start_log
    ||
    ------------------------------------------------------------------*/

PROCEDURE start_log
(
 p_batch_id         IN  pqh_process_log.txn_id%TYPE,
 p_module_cd        IN  pqh_process_log.module_cd%TYPE,
 p_log_context      IN pqh_process_log.log_context%TYPE,
 p_information_category        IN pqh_process_log.information_category%TYPE  DEFAULT NULL,
 p_information1                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information2                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information3                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information4                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information5                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information6                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information7                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information8                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information9                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information10               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information11               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information12               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information13               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information14               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information15               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information16               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information17               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information18               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information19               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information20               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information21               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information22               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information23               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information24               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information25               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information26               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information27               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information28               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information29               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information30               IN pqh_process_log.information1%TYPE  DEFAULT NULL
) IS
--
-- local variables
--
l_proc                  varchar2(72) := g_package||'start_log';
l_process_log_id        pqh_process_log.process_log_id%TYPE;
l_object_version_number pqh_process_log.object_version_number%TYPE;
PRAGMA                  AUTONOMOUS_TRANSACTION;



BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- populate the globals

   g_batch_id  := p_batch_id;
   g_module_cd := p_module_cd;

   hr_utility.set_location('Batch: '||g_batch_id, 10);
   hr_utility.set_location('Module: '||g_module_cd, 15);
   hr_utility.set_location('Context: '||p_log_context, 15);

 --  initialize the pl / sql table

   g_log_tab.DELETE;

-- delete all records for this batch from pqh_process_log table
-- this is a tree structure so delete the entire tree below the batch_id

   DELETE FROM pqh_process_log
   WHERE process_log_id IN
         ( SELECT process_log_id
             FROM pqh_process_log
           START WITH master_process_log_id IS NULL
                  AND txn_id = g_batch_id
                  AND module_cd = g_module_cd
          CONNECT BY PRIOR process_log_id = master_process_log_id
         );


/*
  insert start record in pqh_process_log with message_type_cd = 'START'
*/
-- Insert API call
pqh_process_log_api.create_process_log
(
   p_validate                       => false
  ,p_process_log_id                 => l_process_log_id
  ,p_module_cd                      => g_module_cd
  ,p_txn_id                         => g_batch_id
  ,p_master_process_log_id          => null
  ,p_message_text                   => 'Process Started'
  ,p_message_type_cd                => 'START'
  ,p_batch_status                   => 'PENDING'
  ,p_batch_start_date               => sysdate
  ,p_batch_end_date                 => null
  ,p_txn_table_route_id             => null
  ,p_log_context                    => p_log_context
  ,p_information_category           => p_information_category
  ,p_information1                   => p_information1
  ,p_information2                   => p_information2
  ,p_information3                   => p_information3
  ,p_information4                   => p_information4
  ,p_information5                   => p_information5
  ,p_information6                   => p_information6
  ,p_information7                   => p_information7
  ,p_information8                   => p_information8
  ,p_information9                   => p_information9
  ,p_information10                  => p_information10
  ,p_information11                  => p_information11
  ,p_information12                  => p_information12
  ,p_information13                  => p_information13
  ,p_information14                  => p_information14
  ,p_information15                  => p_information15
  ,p_information16                  => p_information16
  ,p_information17                  => p_information17
  ,p_information18                  => p_information18
  ,p_information19                  => p_information19
  ,p_information20                  => p_information20
  ,p_information21                  => p_information21
  ,p_information22                  => p_information22
  ,p_information23                  => p_information23
  ,p_information24                  => p_information24
  ,p_information25                  => p_information25
  ,p_information26                  => p_information26
  ,p_information27                  => p_information27
  ,p_information28                  => p_information28
  ,p_information29                  => p_information29
  ,p_information30                  => p_information30
  ,p_object_version_number          => l_object_version_number
  ,p_effective_date                 => sysdate
 );


   /*
     For the next txn , this l_process_log_id is the master_l_process_log_id
     we will also need this id to update in end_log
   */

   g_master_process_log_id := l_process_log_id;


   hr_utility.set_location('Process Started  ' ,29);
   hr_utility.set_location('Process_log_id : '||l_process_log_id, 30);
   hr_utility.set_location('OVN : '||l_object_version_number, 40);


 /*
   commit the autonomous transaction
 */

   commit;  -- allowed only in autonomous triggers


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END start_log;

    /*----------------------------------------------------------------
    ||
    ||                   PROCEDURE : insert_log
    ||
    ------------------------------------------------------------------*/

PROCEDURE insert_log
(
 p_message_type_cd             IN pqh_process_log.message_type_cd%TYPE,
 p_message_text                IN pqh_process_log.message_text%TYPE,
 p_information_category        IN pqh_process_log.information_category%TYPE  DEFAULT NULL,
 p_information1                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information2                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information3                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information4                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information5                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information6                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information7                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information8                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information9                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information10               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information11               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information12               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information13               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information14               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information15               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information16               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information17               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information18               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information19               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information20               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information21               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information22               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information23               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information24               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information25               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information26               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information27               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information28               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information29               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information30               IN pqh_process_log.information1%TYPE  DEFAULT NULL
) IS

/*
  Before inserting we check if row is already existing as the same node may have been
  called more then once
*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||'insert_log';
l_txn_id                  pqh_process_log.txn_id%TYPE;
l_log_context             pqh_process_log.log_context%TYPE;
l_txn_table_route_id      pqh_process_log.txn_table_route_id%TYPE;
l_process_log_id          pqh_process_log.process_log_id%TYPE;
l_master_process_log_id   pqh_process_log.master_process_log_id%TYPE;
l_object_version_number   pqh_process_log.object_version_number%TYPE;
l_current_level           NUMBER := 0;
l_message_text            pqh_process_log.message_text%TYPE;
l_message_type_cd         pqh_process_log.message_type_cd%TYPE;
l_row_exists              varchar2(10) := 'N';
l_curr_process_log_id     pqh_process_log.process_log_id%TYPE;
PRAGMA                    AUTONOMOUS_TRANSACTION;

CURSOR csr_row_exists(p_txn_id IN number) is
SELECT 'Y', process_log_id
FROM pqh_process_log
WHERE txn_id = p_txn_id
  AND master_process_log_id IS NOT NULL
START WITH master_process_log_id IS NULL
       AND txn_id = g_batch_id
       AND module_cd = g_module_cd
CONNECT BY prior process_log_id = master_process_log_id;


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  /*
    We will insert error for the current level in g_log_tab
  */

  -- for first record in g_log_tab the master is g_master_process_log_id
   l_master_process_log_id  := g_master_process_log_id;

  -- loop thru the g_log_tab table and insert
  FOR i IN NVL(g_log_tab.FIRST,0)..NVL(g_log_tab.LAST,-999)
  LOOP
/*
     -- call insert API if insert_flag <> 'Y'
     IF NVL(g_log_tab(i).insert_flag,'N') <> 'Y' THEN
*/
     -- call insert API if  l_row_exists <> 'Y
       OPEN csr_row_exists(p_txn_id => g_log_tab(i).txn_id);
          -- initialize l_row_exists and l_curr_process_log_id
           l_row_exists := 'N';
           l_curr_process_log_id := '';
          FETCH csr_row_exists INTO l_row_exists, l_curr_process_log_id;
       CLOSE csr_row_exists;

  hr_utility.set_location('Txn Id : '||g_log_tab(i).txn_id,6);
  hr_utility.set_location('Row Exists : '||l_row_exists,7);
  hr_utility.set_location('curr_process_log_id : '||l_curr_process_log_id,8);

     IF l_row_exists <> 'Y' THEN
        l_txn_id := g_log_tab(i).txn_id ;
        l_txn_table_route_id := g_log_tab(i).txn_table_route_id;
        l_log_context := g_log_tab(i).log_context;

        -- determine the current context to insert the error message
         l_current_level := NVL(g_log_tab.LAST,-999);

           IF i = l_current_level THEN
             l_message_text     := p_message_text;
             l_message_type_cd  := p_message_type_cd;

              -- Insert API call
              pqh_process_log_api.create_process_log
              (
                 p_validate                       => false
                ,p_process_log_id                 => l_process_log_id
                ,p_module_cd                      => g_module_cd
                ,p_txn_id                         => l_txn_id
                ,p_master_process_log_id          => l_master_process_log_id
                ,p_message_text                   => l_message_text
                ,p_message_type_cd                => l_message_type_cd
                ,p_batch_status                   => null
                ,p_batch_start_date               => null
                ,p_batch_end_date                 => null
                ,p_txn_table_route_id             => l_txn_table_route_id
                ,p_log_context                    => l_log_context
                ,p_information_category           => p_information_category
                ,p_information1                   => p_information1
                ,p_information2                   => p_information2
                ,p_information3                   => p_information3
                ,p_information4                   => p_information4
                ,p_information5                   => p_information5
                ,p_information6                   => p_information6
                ,p_information7                   => p_information7
                ,p_information8                   => p_information8
                ,p_information9                   => p_information9
                ,p_information10                  => p_information10
                ,p_information11                  => p_information11
                ,p_information12                  => p_information12
                ,p_information13                  => p_information13
                ,p_information14                  => p_information14
                ,p_information15                  => p_information15
                ,p_information16                  => p_information16
                ,p_information17                  => p_information17
                ,p_information18                  => p_information18
                ,p_information19                  => p_information19
                ,p_information20                  => p_information20
                ,p_information21                  => p_information21
                ,p_information22                  => p_information22
                ,p_information23                  => p_information23
                ,p_information24                  => p_information24
                ,p_information25                  => p_information25
                ,p_information26                  => p_information26
                ,p_information27                  => p_information27
                ,p_information28                  => p_information28
                ,p_information29                  => p_information29
                ,p_information30                  => p_information30
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => sysdate
               );
           ELSE
             l_message_text     := 'No error';
             l_message_type_cd  := 'COMPLETE';

              -- Insert API call
              pqh_process_log_api.create_process_log
              (
                 p_validate                       => false
                ,p_process_log_id                 => l_process_log_id
                ,p_module_cd                      => g_module_cd
                ,p_txn_id                         => l_txn_id
                ,p_master_process_log_id          => l_master_process_log_id
                ,p_message_text                   => l_message_text
                ,p_message_type_cd                => l_message_type_cd
                ,p_batch_status                   => null
                ,p_batch_start_date               => null
                ,p_batch_end_date                 => null
                ,p_txn_table_route_id             => l_txn_table_route_id
                ,p_log_context                    => l_log_context
                ,p_information_category           => null
                ,p_information1                   => null
                ,p_information2                   => null
                ,p_information3                   => null
                ,p_information4                   => null
                ,p_information5                   => null
                ,p_information6                   => null
                ,p_information7                   => null
                ,p_information8                   => null
                ,p_information9                   => null
                ,p_information10                  => null
                ,p_information11                  => null
                ,p_information12                  => null
                ,p_information13                  => null
                ,p_information14                  => null
                ,p_information15                  => null
                ,p_information16                  => null
                ,p_information17                  => null
                ,p_information18                  => null
                ,p_information19                  => null
                ,p_information20                  => null
                ,p_information21                  => null
                ,p_information22                  => null
                ,p_information23                  => null
                ,p_information24                  => null
                ,p_information25                  => null
                ,p_information26                  => null
                ,p_information27                  => null
                ,p_information28                  => null
                ,p_information29                  => null
                ,p_information30                  => null
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => sysdate
               );
           END IF;

/*
              -- Insert API call
              pqh_process_log_api.create_process_log
              (
                 p_validate                       => false
                ,p_process_log_id                 => l_process_log_id
                ,p_module_cd                      => g_module_cd
                ,p_txn_id                         => l_txn_id
                ,p_master_process_log_id          => l_master_process_log_id
                ,p_message_text                   => l_message_text
                ,p_message_type_cd                => l_message_type_cd
                ,p_batch_status                   => null
                ,p_batch_start_date               => null
                ,p_batch_end_date                 => null
                ,p_txn_table_route_id             => l_txn_table_route_id
                ,p_log_context                    => l_log_context
                ,p_information_category           => p_information_category
                ,p_information1                   => p_information1
                ,p_information2                   => p_information2
                ,p_information3                   => p_information3
                ,p_information4                   => p_information4
                ,p_information5                   => p_information5
                ,p_information6                   => p_information6
                ,p_information7                   => p_information7
                ,p_information8                   => p_information8
                ,p_information9                   => p_information9
                ,p_information10                  => p_information10
                ,p_information11                  => p_information11
                ,p_information12                  => p_information12
                ,p_information13                  => p_information13
                ,p_information14                  => p_information14
                ,p_information15                  => p_information15
                ,p_information16                  => p_information16
                ,p_information17                  => p_information17
                ,p_information18                  => p_information18
                ,p_information19                  => p_information19
                ,p_information20                  => p_information20
                ,p_information21                  => p_information21
                ,p_information22                  => p_information22
                ,p_information23                  => p_information23
                ,p_information24                  => p_information24
                ,p_information25                  => p_information25
                ,p_information26                  => p_information26
                ,p_information27                  => p_information27
                ,p_information28                  => p_information28
                ,p_information29                  => p_information29
                ,p_information30                  => p_information30
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => sysdate
               );
*/

             -- mark the current record insert_flag = Y so that this will not be re-inserted
                g_log_tab(i).insert_flag := 'Y';

             -- populate the process_log_id for this record
                g_log_tab(i).process_log_id := l_process_log_id;


                 hr_utility.set_location('Inserted log  Process log id:  '||l_process_log_id,25);
                 hr_utility.set_location('Txn_id : '||l_txn_id, 30);
                 hr_utility.set_location('Txn Route_id : '||l_txn_table_route_id, 50);
                 hr_utility.set_location('OVN : '||l_object_version_number, 100);

      END IF;

      -- for the next record  the current process_log_id is master
        IF l_row_exists = 'Y' THEN
         -- as row exists pick master from table
            l_master_process_log_id :=  l_curr_process_log_id;
        ELSE
          -- pick the new row that was created
            l_master_process_log_id  := g_log_tab(i).process_log_id;
        END IF;


  END LOOP;

 /*
   commit the autonomous transaction
 */

  commit;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        g_Batch_Id  := NULL;
        g_Module_Cd := NULL;
        g_Master_Process_Log_Id := NULL;
        hr_utility.raise_error;
END insert_log;



    /*----------------------------------------------------------------
    ||
    ||                   PROCEDURE : set_context_level
    ||
    ------------------------------------------------------------------*/

PROCEDURE set_context_level
(
 p_txn_id               IN pqh_process_log.txn_id%TYPE,
 p_txn_table_route_id   IN pqh_process_log.txn_table_route_id%TYPE,
 p_level                IN NUMBER,
 p_log_context          IN pqh_process_log.log_context%TYPE DEFAULT NULL
) IS
--
-- local variables
--
l_proc                  varchar2(72) := g_package||'set_context_level';
l_max_level             NUMBER;
l_current_level         NUMBER;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- determine the maximum level in the global table
   l_max_level :=  NVL(g_log_tab.LAST,0);
   l_current_level := p_level;

   hr_utility.set_location('Current Level '||l_current_level,10);
   hr_utility.set_location('Maximum Level '||l_max_level,11);

  -- delete from global table all levels below the current level
    g_log_tab.DELETE(p_level,l_max_level);

  -- check if all the levels above the current level exists else error out
     WHILE  l_current_level > NVL(g_log_tab.FIRST,9999)
      LOOP
        IF NOT g_log_tab.EXISTS(l_current_level - 1) THEN
          hr_utility.set_message(8302, 'PQH_INVALID_MESSAGE_LEVEL');
          hr_utility.raise_error;
        END IF;
         l_current_level := l_current_level - 1;
      END LOOP;

  -- populate the global table with the values
    g_log_tab(p_level).txn_id             := p_txn_id;
    g_log_tab(p_level).txn_table_route_id := p_txn_table_route_id;
    g_log_tab(p_level).level              := p_level;
    g_log_tab(p_level).log_context        := p_log_context;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        g_Batch_Id  := NULL;
        g_Module_Cd := NULL;
        g_Master_Process_Log_Id := NULL;
        hr_utility.raise_error;
END set_context_level;


    /*----------------------------------------------------------------
    ||
    ||                   PROCEDURE : end_log
    ||
    ------------------------------------------------------------------*/

PROCEDURE end_log
IS
--
-- local variables
--
l_proc                  varchar2(72) := g_package||'end_log';
l_count_error           NUMBER := 0;
l_count_warning         NUMBER := 0;
l_status                VARCHAR2(30);

PRAGMA                  AUTONOMOUS_TRANSACTION;

CURSOR csr_status (p_message_type_cd  IN VARCHAR2 ) IS
SELECT COUNT(*)
FROM pqh_process_log
WHERE message_type_cd = p_message_type_cd
START WITH master_process_log_id IS NULL AND txn_id = g_batch_id AND module_cd = g_module_cd
CONNECT BY PRIOR process_log_id = master_process_log_id;


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);


  /*
    Compute the status of the batch. If there exists any record in the batch with
    message_type_cd = 'ERROR' then the batch_status = 'ERROR'
    If there only exists records in the batch with message_type_cd = 'WARNING' then
    the batch_status = 'WARNING'
    If there are NO records in the batch with message_type_cd = 'WARNING' OR 'ERROR' then
    the batch_status = 'SUCCESS'
  */

   OPEN csr_status(p_message_type_cd => 'ERROR');
     FETCH csr_status INTO l_count_error;
   CLOSE csr_status;

   OPEN csr_status(p_message_type_cd => 'WARNING');
     FETCH csr_status INTO l_count_warning;
   CLOSE csr_status;


   IF l_count_error <> 0 THEN
     -- there are one or more errors
      l_status := 'ERROR';
   ELSE
     -- errors are 0 , check for warnings
      IF l_count_warning <> 0 THEN
        -- there are one or more warnings
        l_status := 'WARNING';
      ELSE
        -- no errors or warnings
         l_status := 'SUCCESS';
      END IF;

   END IF;

   hr_utility.set_location('Batch Status :  '||l_status,100);

  /*
    update the 'start' record for this batch with message_type_cd = 'COMPLETE' and
    update the batch_end_date with current date time
  */

   UPDATE pqh_process_log
   SET message_type_cd = 'COMPLETE',
       message_text   = fnd_message.get_string('PQH','PQH_PROCESS_COMPLETED'),
       batch_status = l_status,
       batch_end_date  = sysdate
   WHERE process_log_id = g_master_process_log_id;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

 /*
   commit the autonomous transaction
 */

  commit;

/* Added by vevenkat to reset the Global variables */

  g_Batch_Id  := NULL;
  g_Module_Cd := NULL;
  g_Master_Process_Log_Id := NULL;
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        g_Batch_id  := NULL;
        G_Module_Cd := NULL;
        g_Master_Process_Log_Id := NULL;
        hr_utility.raise_error;
END end_log;



END PQH_PROCESS_BATCH_LOG;

/
