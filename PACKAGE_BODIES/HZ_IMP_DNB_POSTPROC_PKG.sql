--------------------------------------------------------
--  DDL for Package Body HZ_IMP_DNB_POSTPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_DNB_POSTPROC_PKG" AS
/*$Header: ARHLDBPB.pls 120.6 2005/10/30 04:20:27 appldev noship $*/

/*
   This would check if a file has more than zero bytes.
   If it is more than zero bytes, then returns true.
   If it is zero bytes, then it will return false.
*/

  FUNCTION file_populated
    (p_dir_name IN VARCHAR2,
     p_file_name IN VARCHAR2,
     p_operation IN VARCHAR2)
     RETURN  BOOLEAN IS

    l_return_status BOOLEAN;
    l_f_type UTL_FILE.file_type;
    l_buffer VARCHAR2(32767);

  BEGIN
   l_return_status := FALSE;
   l_f_type := UTL_FILE.fopen(p_dir_name,p_file_name, p_operation,32767);
      BEGIN
      UTL_FILE.get_line(l_f_type,l_buffer, 1000);
        IF (LENGTH(l_buffer) > 0) THEN
          l_return_status := TRUE;
        ELSE
           l_return_status := FALSE;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'UTL_FILE.GET_LINE - NO_DATA_FOUND');
          FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
           l_return_status := FALSE;
        WHEN VALUE_ERROR THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'UTL_FILE.GET_LINE - VALUE_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
           l_return_status := FALSE;
     END;
     RETURN l_return_status;
  EXCEPTION
    WHEN UTL_FILE.invalid_path THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'UTL_FILE.FOPEN - invalid path');
        RAISE FND_API.G_EXC_ERROR;
    WHEN UTL_FILE.invalid_mode THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'UTL_FILE.FOPEN - invalid mode');
        RAISE FND_API.G_EXC_ERROR;
    WHEN UTL_FILE.invalid_operation THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'UTL_FILE.FOPEN - invalid operation');
        -- this only means that file did not even get created
        -- that is, all the records were successfull
        l_return_status := FALSE;
     RETURN l_return_status;
    WHEN UTL_FILE.invalid_maxlinesize THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'UTL_FILE.FOPEN - invalid max line size');
        RAISE FND_API.G_EXC_ERROR;
    WHEN others THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END file_populated;


 PROCEDURE POST_PROCESSING (
  errbuf      OUT NOCOPY     VARCHAR2,
  retcode     OUT NOCOPY     VARCHAR2,
  p_batchid  IN             VARCHAR2)IS

  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_tmp        NUMBER;
  l_error_message    fnd_new_messages.message_text%TYPE;
  l_dirname VARCHAR2(4000);
  l_bad_fname VARCHAR2(400);
  l_func_ret  BOOLEAN;

   BEGIN
     -- This would have all the post processing steps
     -- after the DNB adapter popultaing the interface tables.
     -- flow
     -- 0. Check if previous stage is sucessfull or not.
     -- If not sucessfull, then
     --    CleanUp()
     -- else --if sucessful
     --     Call batch activate api()
     --     Analyze stats()
     -- end if;

    --Standard start of API savepoint
    SAVEPOINT dnb_adapter_pp;

    --Initialize API return status to success.
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    retcode := 0;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' bfr calling api batchid:'||p_batchid);

    if (p_batchid is not null) then
      l_tmp := to_number(p_batchid);

     -- 2. Call batch activate api.
    HZ_IMP_BATCH_SUMMARY_V2PUB.activate_batch (
      p_init_msg_list      => FND_API.G_TRUE,
      p_batch_id           => p_batchid,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_error_message);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'batch sumry api ret status:'||l_return_status);

    CASE l_return_status
      WHEN FND_API.G_RET_STS_ERROR THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'HZ_IMP_BATCH_SUMMARY_V2PUB.activate_batch errored');
        RAISE FND_API.G_EXC_ERROR;
      WHEN FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'HZ_IMP_BATCH_SUMMARY_V2PUB.activate_batch errored unexpectedly');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      WHEN FND_API.G_RET_STS_SUCCESS THEN
         retcode := 0;
         -- check to see if the user has any bad data in bad file.
         BEGIN
           SELECT  ARGUMENT1, ARGUMENT4 --, ARGUMENT5
           INTO l_dirname, l_bad_fname
           FROM    FND_CONCURRENT_REQUESTS
           WHERE   PRIORITY_request_id = FND_GLOBAL.CONC_PRIORITY_REQUEST
            AND    program_application_id = FND_GLOBAL.PROG_APPL_ID
            AND   CONCURRENT_PROGRAM_ID =
                       (SELECT CONCURRENT_PROGRAM_ID
                          FROM fnd_concurrent_programs
                         WHERE application_id = FND_GLOBAL.PROG_APPL_ID
                          AND concurrent_program_name = 'ARHLDDNB3');

             FND_FILE.PUT_LINE(FND_FILE.LOG, 'directory name:'||l_dirname);
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'file name:'||l_bad_fname);

             l_func_ret := file_populated(l_dirname,l_bad_fname, 'r');

             IF l_func_ret THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'A bad file is generated. Please check and correct the data');
               retcode := 1;
             ELSE
               retcode := 0;
             END IF;
         END;
       END CASE;
    ELSE
       retcode := 2;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch Id is NULL.Pass a valid batch id');
    end if;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO dnb_adapter_pp;
      retcode := 1;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Expected Error Occured');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '----------------------');
      FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'batchid:'||p_batchid);
      FND_MSG_PUB.Reset;
      --FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      FOR i IN 1..l_msg_count LOOP
        --l_error_message := FND_MESSAGE.get;
        l_error_message :=  FND_MSG_PUB.Get(
             p_msg_index   =>  i,
             p_encoded     =>  FND_API.G_FALSE);
        errbuf  := l_error_message;
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_message);
      END LOOP;
      FND_FILE.close;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO dnb_adapter_pp;
      retcode := 2;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'UnExpected Error Occured');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '----------------------');
      FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'batchid:'||p_batchid);
      FND_MSG_PUB.Reset;
      --FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      FOR i IN 1..l_msg_count LOOP
        --l_error_message := FND_MESSAGE.get;
        l_error_message :=  FND_MSG_PUB.Get(
             p_msg_index   =>  i,
             p_encoded     =>  FND_API.G_FALSE);
        errbuf  := l_error_message;
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_message);
      END LOOP;
      FND_FILE.close;
    WHEN OTHERS THEN
      ROLLBACK TO dnb_adapter_pp;
      retcode := 2;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'SQLERRM: ' || SQLERRM);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'batchid:'||p_batchid);
      FND_MSG_PUB.Reset;
      FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
        l_error_message :=  FND_MSG_PUB.Get(
             p_msg_index   =>  i,
             p_encoded     =>  FND_API.G_FALSE);
        errbuf  := l_error_message;
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_message);
      END LOOP;
      FND_FILE.close;
   END POST_PROCESSING;

END HZ_IMP_DNB_POSTPROC_PKG;

/
