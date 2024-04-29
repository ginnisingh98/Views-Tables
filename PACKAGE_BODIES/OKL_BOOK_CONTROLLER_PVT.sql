--------------------------------------------------------
--  DDL for Package Body OKL_BOOK_CONTROLLER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BOOK_CONTROLLER_PVT" AS
/* $Header: OKLRBCTB.pls 120.8.12010000.4 2009/11/27 06:06:17 rpillay ship $ */
--------------------------------------------------------------------------------
--LOCAL DATASTRUCTURES
--------------------------------------------------------------------------------
TYPE msg_token_rec IS RECORD (
    token_name    VARCHAR2(50) := OKL_API.G_MISS_CHAR,
    token_value   VARCHAR2(300) := OKL_API.G_MISS_CHAR);

TYPE msg_token_tbl IS TABLE OF msg_token_rec
INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
G_INVALID_VALUE             CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN            CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
G_API_TYPE                  CONSTANT VARCHAR2(4)    := '_PVT';


-----------------------------------------------------------------------------
-- FUNCTION get_message
-----------------------------------------------------------------------------
-- Start of comments
--
-- Function Name   : get_message
-- Description     : This procedure gets the translated mesg to
--                  be put into output files.
-- Business Rules  :
-- Parameters      : p_msg_name,p_token_name,p_token_value
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

FUNCTION get_message(
     p_msg_name     IN VARCHAR2,
     p_token_name   IN VARCHAR2,
     p_token_value  IN VARCHAR2)
  RETURN VARCHAR2 IS

  l_message  VARCHAR2(2000);
BEGIN
  IF p_msg_name IS NOT NULL THEN
     --create mesg to print in o/p files of requests
     fnd_message.set_name(application => G_APP_NAME,
                          name        => p_msg_name);

     fnd_message.set_token(token => p_token_name,
                           value => p_token_value);

     l_message := fnd_message.get();
  END IF;
  RETURN l_message;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_message;

-----------------------------------------------------------------------------
-- FUNCTION get_message
-----------------------------------------------------------------------------
-- Start of comments
--
-- Function Name   : get_message
-- Description     : This procedure gets the translated mesg to
--                   be put into output files.
-- Business Rules  :
-- Parameters      : p_msg_name,p_token_name,p_token_value
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

FUNCTION get_message(
     p_msg_name        IN VARCHAR2,
     p_msg_tokens_tbl  IN msg_token_tbl)
  RETURN VARCHAR2 IS

  l_message  VARCHAR2(2000);
BEGIN
  IF p_msg_name IS NOT NULL THEN
     --create mesg for to print in o/p filse of requests
     fnd_message.set_name(application => G_APP_NAME,
                          name        => p_msg_name);

     FOR i IN p_msg_tokens_tbl.FIRST..p_msg_tokens_tbl.LAST
     LOOP
     fnd_message.set_token(token => p_msg_tokens_tbl(i).token_name,
                           value => p_msg_tokens_tbl(i).token_value);

     END LOOP;
     l_message := fnd_message.get();
  END IF;
  RETURN l_message;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_message;

-----------------------------------------------------------------------------
-- FUNCTION get_batch_id
-----------------------------------------------------------------------------
-- Start of comments
--
-- Function Name   : get_batch_id
-- Description     : This procedure generates the batch id for controller
--                   trx table from sequence.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

FUNCTION get_batch_id RETURN NUMBER IS
  l_batch_num  OKL_BOOK_CONTROLLER_TRX.BATCH_NUMBER%TYPE;

  CURSOR get_batch_num IS
  SELECT OKL_BKG_CONTL_SEQ.NEXTVAL
  FROM DUAL;

BEGIN
  --get batch id for conc requests from seq
  OPEN get_batch_num;
  FETCH get_batch_num INTO l_batch_num;
  CLOSE get_batch_num;

  RETURN l_batch_num;

EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END get_batch_id;

-----------------------------------------------------------------------------
-- FUNCTION populate_ctrl_trx_rec
-----------------------------------------------------------------------------
-- Start of comments
--
-- Function Name   : populate_ctrl_trx_rec
-- Description     : This populates book_controller_trx record
-- Business Rules  :
-- Parameters      : p_batch_num,p_srl_num,p_khr_id,p_prog_name,
--                   p_prog_short_name
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

FUNCTION populate_ctrl_trx_rec(
     p_batch_num       IN OKL_BOOK_CONTROLLER_TRX.BATCH_NUMBER%TYPE,
     p_srl_num         IN OKL_BOOK_CONTROLLER_TRX.PROCESSING_SRL_NUMBER%TYPE,
     p_khr_id          IN OKC_K_HEADERS_B.ID%TYPE,
     p_prog_name       IN OKL_BOOK_CONTROLLER_TRX.PROGRAM_NAME%TYPE,
     p_prog_short_name IN OKL_BOOK_CONTROLLER_TRX.PROG_SHORT_NAME%TYPE,
     p_active_flag     IN VARCHAR2 DEFAULT NULL,
     p_progress_status IN OKL_BOOK_CONTROLLER_TRX.PROGRESS_STATUS%TYPE)
  RETURN bct_rec_type IS

  l_bct_rec   bct_rec_type;
BEGIN
  --populate book_controller_trx record
  l_bct_rec.user_id := fnd_global.user_id;
  l_bct_rec.org_id := mo_global.get_current_org_id;
  l_bct_rec.batch_number := p_batch_num;
  l_bct_rec.processing_srl_number := p_srl_num;
  l_bct_rec.khr_id := p_khr_id;
  l_bct_rec.program_name := p_prog_name;
  l_bct_rec.prog_short_name := p_prog_short_name;
  l_bct_rec.progress_status := p_progress_status;
  l_bct_rec.active_flag := p_active_flag;

  RETURN l_bct_rec;

EXCEPTION
  WHEN OTHERS THEN
    null;
END populate_ctrl_trx_rec;


-----------------------------------------------------------------------------
-- PROCEDURE populate_book_ctrl_trx
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : populate_book_ctrl_trx
-- Description     : Procedure to insert the processes to be executed for the
--                   requested contract stage.
-- Business Rules  :
-- Parameters      : p_khr_id,p_cont_stage,p_draft_journal_entry,
--                   p_curr_sts_code,x_batch_number
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE populate_book_ctrl_trx(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE,
     p_cont_stage          IN  VARCHAR2,
     p_draft_journal_entry IN  VARCHAR2,
     p_curr_sts_code       IN  VARCHAR2,
     x_batch_number        OUT NOCOPY NUMBER) IS

  l_api_name        CONSTANT VARCHAR2(30) := 'populate_book_ctrl_trx';
  l_api_version     CONSTANT NUMBER := 1.0;
  l_batch_num       OKL_BOOK_CONTROLLER_TRX.BATCH_NUMBER%TYPE;
  l_bct_tbl         bct_tbl_type;
  lx_bct_tbl        bct_tbl_type;
  i                 NUMBER;

  CURSOR c_book_ctrl_trx(p_khr_id NUMBER) IS
  SELECT *
  FROM okl_book_controller_trx
  WHERE khr_id = p_khr_id
  AND   NVL(active_flag,'N') = 'Y';

  l_book_ctrl_trx c_book_ctrl_trx%ROWTYPE;
  l_qa_progress_status okl_book_controller_trx.progress_status%TYPE;
  l_ut_progress_status okl_book_controller_trx.progress_status%TYPE;
  l_st_progress_status okl_book_controller_trx.progress_status%TYPE;
  l_bk_progress_status okl_book_controller_trx.progress_status%TYPE;
  lx_batch_number   NUMBER;

BEGIN
  x_batch_number  := null;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

   -- check if activity started successfully
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Initialize records in okl_book_controller_trx table

     OKL_BOOK_CONTROLLER_PVT.init_book_controller_trx(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_khr_id         => p_khr_id,
            x_batch_number   => lx_batch_number);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

  OPEN c_book_ctrl_trx(p_khr_id  => p_khr_id);
  LOOP
     FETCH c_book_ctrl_trx INTO l_book_ctrl_trx;
     IF (l_book_ctrl_trx.prog_short_name = 'OKLBCTQA') THEN
         l_qa_progress_status := l_book_ctrl_trx.progress_status;
     ELSIF (l_book_ctrl_trx.prog_short_name = 'OKLBCTUT') THEN
         l_ut_progress_status := l_book_ctrl_trx.progress_status;
     ELSIF (l_book_ctrl_trx.prog_short_name = 'OKLBCTST') THEN
         l_st_progress_status := l_book_ctrl_trx.progress_status;
     ELSIF (l_book_ctrl_trx.prog_short_name = 'OKLBCTBK') THEN
         l_bk_progress_status := l_book_ctrl_trx.progress_status;
     END IF;
     EXIT WHEN c_book_ctrl_trx%NOTFOUND;
  END LOOP;
  CLOSE c_book_ctrl_trx;

  --get new batch number from sequence
  IF (l_qa_progress_status <> 'COMPLETE' OR l_ut_progress_status <> 'COMPLETE' OR l_st_progress_status <> 'COMPLETE'
      OR l_bk_progress_status <> 'COMPLETE') THEN
  l_batch_num := get_batch_id;
  END IF;

  IF(l_batch_num IS NULL OR l_batch_num = OKL_API.G_MISS_NUM) THEN
    --raise error if batch number could not be generated from seq.
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: batch number could not be generated');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  i := 0;
  IF (p_cont_stage IN ('OKLBCTQA','OKLBCTUT','OKLBCTST','OKLBCTBK') AND l_qa_progress_status <> 'COMPLETE') THEN
      --populate record for QA Validation
      i := i+1;
      l_bct_tbl(i) := populate_ctrl_trx_rec(
                        p_batch_num       => l_batch_num,
                        p_srl_num         => 10,
                        p_khr_id          => p_khr_id,
                        p_prog_name       => 'OKLBCTQA',
                        p_prog_short_name => 'OKLBCTQA',
                        p_progress_status => 'PENDING');
  END IF;

  IF (p_cont_stage IN ('OKLBCTUT','OKLBCTST','OKLBCTBK') AND l_ut_progress_status <> 'COMPLETE') THEN
      --populate record for Calculate Upfront Tax
      i := i+1;
      l_bct_tbl(i) := populate_ctrl_trx_rec(
                        p_batch_num       => l_batch_num,
                        p_srl_num         => 20,
                        p_khr_id          => p_khr_id,
                        p_prog_name       => 'OKLBCTUT',
                        p_prog_short_name => 'OKLBCTUT',
                        p_progress_status => 'PENDING');
  END IF;

  IF (p_cont_stage IN ('OKLBCTST','OKLBCTBK') AND l_st_progress_status <> 'COMPLETE') THEN
    --populate record for Price Contract
    i := i+1;
    l_bct_tbl(i) := populate_ctrl_trx_rec(
                      p_batch_num       => l_batch_num,
                      p_srl_num         => 30,
                      p_khr_id          => p_khr_id,
                      p_prog_name       => 'OKLBCTST',
                      p_prog_short_name => 'OKLBCTST',
                      p_progress_status => 'PENDING');
  END IF;

  IF (p_cont_stage = 'OKLBCTBK' AND l_bk_progress_status <> 'COMPLETE') THEN
    IF (p_curr_sts_code <> 'APPROVED') THEN
       --populate record for Approval
       i := i+1;
       l_bct_tbl(i) := populate_ctrl_trx_rec(
                         p_batch_num       => l_batch_num,
                         p_srl_num         => 40,
                         p_khr_id          => p_khr_id,
                         p_prog_name       => 'OKLBCTAP',
                         p_prog_short_name => 'OKLBCTAP',
                         p_progress_status => 'PENDING');
    END IF;
    --populate record for Activation
    i := i+1;
    l_bct_tbl(i) := populate_ctrl_trx_rec(
                      p_batch_num       => l_batch_num,
                      p_srl_num         => 50,
                      p_khr_id          => p_khr_id,
                      p_prog_name       => 'OKLBCTBK',
                      p_prog_short_name => 'OKLBCTBK',
                      p_progress_status => 'PENDING');

  END IF;

  IF l_bct_tbl.COUNT > 0 THEN
    --insert records into controller tranasction table for the batch
    okl_bct_pvt.insert_row(
                 p_api_version   => p_api_version,
                 p_init_msg_list => p_init_msg_list,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 p_bct_tbl       => l_bct_tbl,
                 x_bct_tbl       => lx_bct_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    COMMIT;
  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'contract already in desired status');
  END IF;

  x_batch_number := l_batch_num;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

END populate_book_ctrl_trx;


-----------------------------------------------------------------------------
-- PROCEDURE update_book_ctrl_trx
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_book_ctrl_trx
-- Description     : Procedure to update controller transaction table with
--                   the concurrent request id and status of the individual
--                   concurrent requests.
-- Business Rules  :
-- Parameters      : p_batch_num,p_srl_num,p_prog_status,p_request_id,
--                   x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE update_book_ctrl_trx(
     p_batch_num      IN okl_book_controller_trx.batch_number%TYPE,
     p_srl_num        IN okl_book_controller_trx.processing_srl_number%TYPE,
     p_prog_status    IN okl_book_controller_trx.progress_status%TYPE,
     p_request_id     IN okl_book_controller_trx.conc_req_id%TYPE,
     x_return_status  OUT NOCOPY VARCHAR2) IS

  l_api_name        CONSTANT VARCHAR2(30) := 'update_book_ctrl_trx';
  l_api_version     CONSTANT NUMBER := 1.0;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list   VARCHAR2(1) := 'T';
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_bct_rec         bct_rec_type;
  x_bct_rec         bct_rec_type;

BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  --start activity
  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => l_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => l_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => l_return_status);

  --raise exception if error during start activity
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --check batch number is not null
  IF (p_batch_num IS NULL OR p_batch_num = OKL_API.G_MISS_NUM) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:batch number is null in call to update okl_book_controller_trx');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSE
    l_bct_rec.batch_number := p_batch_num;
  END IF;

  --check processing serial number is not null
  IF (p_srl_num IS NULL OR p_srl_num = OKL_API.G_MISS_NUM) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:processing srl number is null in call to update okl_book_controller_trx');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSE
    l_bct_rec.processing_srl_number := p_srl_num;
  END IF;

  --if request status is not null, update request status
  IF (p_prog_status IS NOT NULL AND p_prog_status <> OKL_API.G_MISS_CHAR) THEN
    l_bct_rec.progress_status := p_prog_status;
  END IF;

  --if request id is not null, update request id
  IF (p_request_id IS NOT NULL AND p_request_id <> OKL_API.G_MISS_NUM) THEN
    l_bct_rec.conc_req_id := p_request_id;
  END IF;

  --call TAPI to update okl_book_controller_trx
  okl_bct_pvt.update_row(
                p_api_version   => l_api_version,
                p_init_msg_list => l_init_msg_list,
                x_return_status => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data,
                p_bct_rec       => l_bct_rec,
                x_bct_rec       => x_bct_rec);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  COMMIT;

  --end activity
  OKL_API.END_ACTIVITY(x_msg_count => l_msg_count,
                       x_msg_data  => l_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => l_msg_count,
        x_msg_data  => l_msg_data,
        p_api_type  => g_api_type);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => l_msg_count,
        x_msg_data  => l_msg_data,
        p_api_type  => g_api_type);

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => l_msg_count,
        x_msg_data  => l_msg_data,
        p_api_type  => g_api_type);

END update_book_ctrl_trx;

-----------------------------------------------------------------------------
-- PROCEDURE submit_controller_prg1
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : submit_controller_prg1
-- Description     : Procedure to submit request for controller program 1
-- Business Rules  :
-- Parameters      : p_khr_id,p_cont_stage,p_draft_journal_entry
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE submit_controller_prg1(
     p_api_version         IN NUMBER,
     p_init_msg_list       IN VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN okc_k_headers_b.id%TYPE,
     p_cont_stage          IN VARCHAR2,
     p_draft_journal_entry IN VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'submit_controller_prg1';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_req_id        NUMBER := 0;

  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_batch_number     okl_book_controller_trx.batch_number%TYPE;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_curr_sts_code    okc_k_headers_b.sts_code%TYPE;

  --cursor the fetch the current status of the contract
  CURSOR get_curr_sts_code(p_khr_id  okc_k_headers_b.id%TYPE) IS
  SELECT sts_code
  FROM okc_k_headers_b
  WHERE id = p_khr_id;


BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  --raise exception if error during start activity
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --fetch the current status of the contract
  OPEN get_curr_sts_code(p_khr_id);
  FETCH get_curr_sts_code INTO l_curr_sts_code;
  IF get_curr_sts_code%NOTFOUND THEN
    l_curr_sts_code := 'XXX'; --dummy value which does not match any status
  END IF;
  CLOSE get_curr_sts_code;

  --populate controller transaction table with the steps to be executed
  --to get the contract to the requested stage.
  populate_book_ctrl_trx(
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_khr_id              => p_khr_id,
      p_cont_stage          => p_cont_stage,
      p_draft_journal_entry => p_draft_journal_entry,
      p_curr_sts_code       => l_curr_sts_code,
      x_batch_number        => l_batch_number);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to populate_book_ctrl_trx');
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in call to populate_book_ctrl_trx');
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --submit concurrent request for Controller Program 1
  FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
  l_req_id := fnd_request.submit_request(
                     application => 'OKL',
                     program     => 'OKLBCTC1',
                     description => 'Controller Program 1',
                     argument1   => p_khr_id,
                     argument2   => p_cont_stage,
                     argument3   => p_draft_journal_entry,
                     argument4   => 'UI');

  --Raise Error if the request has not been submitted successfully.
  IF l_req_id = 0 THEN
    okl_api.set_message(p_app_name     => 'OKL',
                        p_msg_name     => 'OKL_CONC_REQ_ERROR',
                        p_token1       => 'PROG_NAME',
                        p_token1_value => 'Controller Program 1',
                        p_token2       => 'REQUEST_ID',
                        p_token2_value => l_req_id);
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);
END submit_controller_prg1;

-----------------------------------------------------------------------------
-- PROCEDURE submit_controller_prg2
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : submit_controller_prg2
-- Description     : Procedure to submit request for controller program 2.
--                   Called from Approval workflow
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE submit_controller_prg2(
     p_api_version    IN NUMBER,
     p_init_msg_list  IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count      OUT NOCOPY NUMBER,
     x_msg_data       OUT NOCOPY VARCHAR2,
     p_khr_id         IN okc_k_headers_b.id%TYPE) IS

  --cursor to check if the contract passed is being
  --booked through concurrent requests and has been
  --requested for Activation.
  CURSOR book_ctrl_trx_csr(
           p_khr_id okl_book_controller_trx.khr_id%TYPE) IS
  SELECT '1'
  FROM okl_book_controller_trx
  WHERE khr_id = p_khr_id
  AND progress_status = 'PENDING'
  AND prog_short_name = 'OKLBCTBK'
  AND NVL(active_flag,'N') = 'N';

  l_api_name           CONSTANT VARCHAR2(30) := 'submit_controller_prg2';
  l_api_version        CONSTANT NUMBER := 1.0;
  l_req_id             NUMBER := 0;
  l_dummy              VARCHAR2(1);
  l_conc_req_activate  BOOLEAN;

BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_conc_req_activate := FALSE;

  --check if contract is being booked thru conc requests
  OPEN book_ctrl_trx_csr(p_khr_id);
  FETCH book_ctrl_trx_csr INTO l_dummy;
  IF book_ctrl_trx_csr%FOUND THEN
    l_conc_req_activate := TRUE;
  END IF;
  CLOSE book_ctrl_trx_csr;

  --if booking being triggered from concurrent request..
  --submit request for contract activation
  IF(l_conc_req_activate = TRUE) THEN
    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
    l_req_id := fnd_request.submit_request(
                       application => 'OKL',
                       program     => 'OKLBCTC2',
                       description => 'Controller Program 2',
                       argument1   => p_khr_id);

    IF l_req_id = 0 THEN
      -- Raise Error if the request has not been submitted successfully.
      Okl_Api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_CONC_REQ_ERROR',
                          p_token1       => 'PROG_NAME',
                          p_token1_value => 'Controller Program 2',
                          p_token2       => 'REQUEST_ID',
                          p_token2_value => l_req_id);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN

    --close all open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

    --close all open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OTHERS THEN

    --close all open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

END submit_controller_prg2;

-----------------------------------------------------------------------------
-- PROCEDURE submit_request
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : submit_request
-- Description     : Common procedure to submit all the concurrent requests
-- Business Rules  :
-- Parameters      : p_program_name,p_description,p_khr_id,p_batch_number
--                   p_serial_num,x_req_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE submit_request(
     p_program_name  IN  VARCHAR2,
     p_description   IN  VARCHAR2,
     p_khr_id        IN  okc_k_headers_b.id%TYPE,
     p_batch_number  IN  NUMBER,
     p_serial_num    IN  NUMBER,
     x_req_status    OUT NOCOPY VARCHAR2) IS

  l_request_id     NUMBER := 0;
  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  --parameters for wait logic
  l_req_status     BOOLEAN;
  l_phase          VARCHAR2(10);
  l_status         VARCHAR2(10);
  l_dev_phase      VARCHAR2(10);
  l_dev_status     VARCHAR2(10);
  l_message        VARCHAR2(1000);
  l_data           VARCHAR2(2000);
  l_msg_index_out  NUMBER;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_api_version    NUMBER := 1.0;
  l_init_msg_list  VARCHAR2(1) := OKL_API.G_TRUE;
  l_program_name   OKL_BOOK_CONTROL_TRX_ALL.prog_short_name%TYPE;

BEGIN
  x_req_status  :=  'S';

  IF (p_program_name = 'OKLBCTAP') THEN
     l_program_name := 'OKLBCTBK';
  ELSE
    l_program_name := p_program_name;
  END IF;
  --submit concurrent request using fnd_request
  FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
  l_request_id := fnd_request.submit_request(
                       application => 'OKL',
                       program     => p_program_name,
                       description => p_description,
                       argument1   => p_khr_id);

  --if request is not submitted successfully,update the
  --request status as ERROR in controller transaction table and
  --set return status to E.
  IF l_request_id = 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**** Error:Could not submit request for '||p_description);

    update_book_controller_trx(
        p_api_version     => l_api_version,
        p_init_msg_list   => l_init_msg_list,
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data,
        p_khr_id          => p_khr_id,
        p_prog_short_name => l_program_name,
        p_conc_req_id     => NULL,
        p_progress_status => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_book_ctrl_trx(
        p_batch_num     => p_batch_number,
        p_srl_num       => p_serial_num,
        p_prog_status   => 'ERROR',
        p_request_id    => null,
        x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_req_status  :=  'E';
  --if request is submitted successfully
  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'**** Request ID: '||l_request_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'**** Monitoring request: '||l_request_id);

    --update the request id and status as RUNNING in controller trx table

    update_book_controller_trx(
        p_api_version     => l_api_version,
        p_init_msg_list   => l_init_msg_list,
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data,
        p_khr_id          => p_khr_id,
        p_prog_short_name => l_program_name,
        p_conc_req_id     => l_request_id,
        p_progress_status => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_RUNNING);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_book_ctrl_trx(
        p_batch_num     => p_batch_number,
        p_srl_num       => p_serial_num,
        p_prog_status   => 'RUNNING',
        p_request_id    => l_request_id,
        x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --wait logic to wait for concurrent request to complete.
    l_req_status := fnd_concurrent.wait_for_request(
                                     l_request_id,
                                     5,
                                     0,
                                     l_phase,
                                     l_status,
                                     l_dev_phase,
                                     l_dev_status,
                                     l_message);

    --if the request errors out, update the controller trx table with request
    --status as ERROR and update return status to E for submit request
    IF l_dev_status = 'ERROR' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** Request '||l_request_id||' failed.');

      update_book_controller_trx(
          p_api_version     => l_api_version,
          p_init_msg_list   => l_init_msg_list,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          p_khr_id          => p_khr_id,
          p_prog_short_name => l_program_name,
          p_progress_status => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      update_book_ctrl_trx(
          p_batch_num     => p_batch_number,
          p_srl_num       => p_serial_num,
          p_prog_status   => 'ERROR',
          p_request_id    => null,
          x_return_status => l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      x_req_status  :=  'E';

    --if request completes successfully, update the request status as
    --COMPLETE in controller trx table.
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** Request '||l_request_id||' Completed.');

      update_book_controller_trx(
          p_api_version     => l_api_version,
          p_init_msg_list   => l_init_msg_list,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          p_khr_id          => p_khr_id,
          p_prog_short_name => l_program_name,
          p_progress_status => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      update_book_ctrl_trx(
         p_batch_num     => p_batch_number,
         p_srl_num       => p_serial_num,
         p_prog_status   => 'COMPLETE',
         p_request_id    => null,
         x_return_status => l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
  END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    x_req_status  :=  'E';

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    x_req_status  :=  'E';

  WHEN OTHERS THEN
    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    x_req_status  :=  'E';

END submit_request;

-----------------------------------------------------------------------------
-- PROCEDURE exec_controller_prg1
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : exec_controller_prg1
-- Description     : Procedure called from concurrent request Controller
--                   Program 1 to execute contract booking.
-- Business Rules  :
-- Parameters      : p_khr_id,p_cont_stage,p_draft_journal_entry
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE exec_controller_prg1(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE,
     p_cont_stage          IN  VARCHAR2,
     p_draft_journal_entry IN  VARCHAR2 DEFAULT 'NO',
     p_called_from         IN  VARCHAR2 DEFAULT 'FORM') IS

  l_api_name         CONSTANT VARCHAR2(30) := 'exec_controller_prg1';
  l_api_version      CONSTANT NUMBER := 1.0;
  --p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_batch_number     okl_book_controller_trx.batch_number%TYPE;
  l_curr_sts_code    okc_k_headers_b.sts_code%TYPE;
  l_approval_path    VARCHAR2(30) := 'NONE';
  l_req_status       VARCHAR2(1);
  USER_EXCEPTION     EXCEPTION;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;

  --cursor to fetch the processes/steps to be executed
  --for the passed batch number.
  CURSOR book_ctrl_trx_csr(
           p_khr_id NUMBER) IS
  SELECT * FROM okl_book_controller_trx
  WHERE khr_id = p_khr_id
  AND progress_status = 'PENDING'
  AND nvl(active_flag,'N') = 'N'
  ORDER BY processing_srl_number;

  --cursor the fetch the current status of the contract
  CURSOR get_curr_sts_code(p_khr_id  okc_k_headers_b.id%TYPE) IS
  SELECT sts_code
  FROM okc_k_headers_b
  WHERE id = p_khr_id;

BEGIN
  p_retcode := 0;
  /*l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;*/

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKL: Contract Booking Controller Started');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  IF (p_called_from = 'FORM') THEN

    --fetch the current status of the contract
    OPEN get_curr_sts_code(p_khr_id);
    FETCH get_curr_sts_code INTO l_curr_sts_code;
    IF get_curr_sts_code%NOTFOUND THEN
      l_curr_sts_code := 'XXX'; --dummy value which does not match any status
    END IF;
    CLOSE get_curr_sts_code;

    --populate controller transaction table with the steps to be executed
    --to get the contract to the requested stage.
    populate_book_ctrl_trx(
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_khr_id              => p_khr_id,
      p_cont_stage          => p_cont_stage,
      p_draft_journal_entry => p_draft_journal_entry,
      p_curr_sts_code       => l_curr_sts_code,
      x_batch_number        => l_batch_number);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to populate_book_ctrl_trx');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in call to populate_book_ctrl_trx');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --check for batch number to be not null.
    --Raise exception if batch number is not generated
    IF(l_batch_number IS NULL OR l_batch_number = OKL_API.G_MISS_NUM) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'batch number could not be generated');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    COMMIT;

  END IF; --p_called_from = 'FORM'

  --fetch the concurrent requests to be submitted for the current batch
  --and submit them with wait logic.
  FOR each_ctrl_trx IN book_ctrl_trx_csr(p_khr_id)
  LOOP
    l_req_status := 'S';
    l_batch_number := each_ctrl_trx.batch_number;

    --concurrent request for QA validation..start
    IF (each_ctrl_trx.prog_short_name = 'OKLBCTQA') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Validation Program Submitted');
      --submit request for QA Validation
          FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
          submit_request(
           p_program_name => each_ctrl_trx.prog_short_name,
           p_description  => 'QA Validation Request',
           p_khr_id       => each_ctrl_trx.khr_id,
           p_batch_number => l_batch_number,
           p_serial_num   => each_ctrl_trx.processing_srl_number,
           x_req_status   => l_req_status);

      IF (l_req_status = 'E') THEN
        RAISE USER_EXCEPTION;
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Validation Program Completed with Status 0');
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    END IF;
    --concurrent request for QA validation..end

    --concurrent request for Calculate Upfront Tax..start
    IF (each_ctrl_trx.prog_short_name = 'OKLBCTUT') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Calculate Upfront Tax Program Submitted');
      --submit request for Upfront tax
          FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
          submit_request(
           p_program_name => each_ctrl_trx.prog_short_name,
           p_description  => 'Calculate Upfront Tax Request',
           p_khr_id       => each_ctrl_trx.khr_id,
           p_batch_number => l_batch_number,
           p_serial_num   => each_ctrl_trx.processing_srl_number,
           x_req_status   => l_req_status);

      IF (l_req_status = 'E') THEN
        RAISE USER_EXCEPTION;
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Calculate Upfront Tax Program Completed with Status 0');
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    END IF;
    --concurrent request for Upfront Tax..end

    --concurrent request for stream generation..start
    IF (each_ctrl_trx.prog_short_name = 'OKLBCTST') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Stream Generation Program Submitted');
      FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
      --submit request for Stream Generation
      submit_request(
           p_program_name => each_ctrl_trx.prog_short_name,
           p_description  => 'Stream Generation Request',
           p_khr_id       => each_ctrl_trx.khr_id,
           p_batch_number => l_batch_number,
           p_serial_num   => each_ctrl_trx.processing_srl_number,
           x_req_status   => l_req_status);

      IF (l_req_status = 'E') THEN
        RAISE USER_EXCEPTION;
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Stream Generation Program Completed with Status 0');
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    END IF;
    --concurrent request for stream generation..end

    /*--concurrent request for draft journal entries..start
    IF (each_ctrl_trx.prog_short_name = 'OKLBCTJE') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Journal Entries Program Submitted');
      FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
      --submit request for Draft journal Entry
      submit_request(
           p_program_name => each_ctrl_trx.prog_short_name,
           p_description  => 'Journal Entries Request',
           p_khr_id       => each_ctrl_trx.khr_id,
           p_batch_number => l_batch_number,
           p_serial_num   => each_ctrl_trx.processing_srl_number,
           x_req_status   => l_req_status);

      IF (l_req_status = 'E') THEN
        RAISE USER_EXCEPTION;
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Journal Entries Completed with Status 0');
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    END IF;
    --concurrent request for draft journal entries..end */

    --concurrent request for Approval..start
    IF (each_ctrl_trx.prog_short_name = 'OKLBCTAP') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Approval Program Submitted');
      FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
      --submit request for Contract Approval
      submit_request(
           p_program_name => each_ctrl_trx.prog_short_name,
           p_description  => 'Approval Request',
           p_khr_id       => each_ctrl_trx.khr_id,
           p_batch_number => l_batch_number,
           p_serial_num   => each_ctrl_trx.processing_srl_number,
           x_req_status   => l_req_status);

      IF (l_req_status = 'E') THEN
        RAISE USER_EXCEPTION;
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Approval Program Completed with Status 0');
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    END IF;
    --concurrent request for approval..end

    --concurrent request for Activate..start
    IF (each_ctrl_trx.prog_short_name = 'OKLBCTBK') THEN

      --read profile for contract approval path
      l_approval_path := fnd_profile.value('OKL_LEASE_CONTRACT_APPROVAL_PROCESS');

      --if no approval path is set or contract activation is only
      --process requested then submit request for Activation
      IF (l_curr_sts_code = 'APPROVED' OR
          NVL(l_approval_path,'NONE') = 'NONE') THEN

        FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Activation Program Submitted');
       FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
       --submit request for Contract Activation
        submit_request(
           p_program_name => each_ctrl_trx.prog_short_name,
           p_description  => 'Contract Activation Request',
           p_khr_id       => each_ctrl_trx.khr_id,
           p_batch_number => l_batch_number,
           p_serial_num   => each_ctrl_trx.processing_srl_number,
           x_req_status   => l_req_status);

        IF (l_req_status = 'E') THEN
        RAISE USER_EXCEPTION;
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Activation Program Completed with Status 0');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
      END IF; --end condition for approval path

    END IF;
    --concurrent request for Activate..end

  END LOOP;--end submitting all requests

  --OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKL: Contract Booking Controller Completed with Status 0');

EXCEPTION
  WHEN USER_EXCEPTION THEN
    p_retcode := 0;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKL: Contract Booking Controller Completed With Errors');

    --close all open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;
    IF get_curr_sts_code%ISOPEN THEN
      CLOSE get_curr_sts_code;
    END IF;

    --update all PENDING steps of the batch to ABANDONED
    FOR each_ctrl_trx IN book_ctrl_trx_csr(p_khr_id)
    LOOP
      update_book_ctrl_trx(
         p_batch_num     => l_batch_number,
         p_srl_num       => each_ctrl_trx.processing_srl_number,
         p_prog_status   => 'ABANDONED',
         p_request_id    => null,
         x_return_status => l_return_status);
    END LOOP;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;

    --close all open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;
    IF get_curr_sts_code%ISOPEN THEN
      CLOSE get_curr_sts_code;
    END IF;

    /*l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);*/

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;

    --close all open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;
    IF get_curr_sts_code%ISOPEN THEN
      CLOSE get_curr_sts_code;
    END IF;

    /*l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);*/

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;

    --close all open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;
    IF get_curr_sts_code%ISOPEN THEN
      CLOSE get_curr_sts_code;
    END IF;

    /*l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OTHERS',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);*/

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END exec_controller_prg1;


-----------------------------------------------------------------------------
-- PROCEDURE exec_controller_prg2
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : exec_controller_prg2
-- Description     : Procedure called from concurrent request Controller
--                   Program 2 to execute contract booking activation
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE exec_controller_prg2(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'exec_controller_prg2';
  /*l_api_version      CONSTANT NUMBER := 1.0;
  p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);*/
  l_req_status       VARCHAR2(1);
  USER_EXCEPTION     EXCEPTION;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;

  --cursor to fetch the processes/steps to be executed
  --for the passed batch number.
  CURSOR book_ctrl_trx_csr(
           p_khr_id okl_book_controller_trx.khr_id%TYPE) IS
  SELECT * FROM okl_book_controller_trx
  WHERE khr_id = p_khr_id
  AND progress_status = 'PENDING'
  AND nvl(active_flag,'N') = 'N'
  ORDER BY processing_srl_number;


BEGIN
  p_retcode := 0;
  /*l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;*/

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKL: Contract Booking Controller Started');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  --call the concurrent program for activation
  FOR each_ctrl_trx IN book_ctrl_trx_csr(p_khr_id)
  LOOP
    l_req_status := 'S';
    --concurrent request for Activation..start
    IF (each_ctrl_trx.prog_short_name = 'OKLBCTBK') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Activation Program Submitted');
      FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
      --submit request for Contract Activation
      submit_request(
           p_program_name => each_ctrl_trx.prog_short_name,
           p_description  => 'Contract Activation Request',
           p_khr_id       => each_ctrl_trx.khr_id,
           p_batch_number => each_ctrl_trx.batch_number,
           p_serial_num   => each_ctrl_trx.processing_srl_number,
           x_req_status   => l_req_status);

      IF (l_req_status = 'E') THEN
        RAISE USER_EXCEPTION;
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '**** OKL: Contract Activation Program Completed with Status 0');
    END IF;
    --concurrent request for Activation..end
  END LOOP;

  --OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKL: Contract Booking Controller Completed with Status 0');

EXCEPTION
  WHEN USER_EXCEPTION THEN
    p_retcode := 0;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Contract Activation Failed');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKL: Contract Booking Controller Completed with Errors');

  /*WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;

    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    -- print the error message in the log file
    Okl_Accounting_Util.get_error_message(g_error_msg);
    IF (g_error_msg.COUNT > 0) THEN
      FOR i IN g_error_msg.FIRST..g_error_msg.LAST
      LOOP
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, g_error_msg(i));
      END LOOP;
    END IF;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;

    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    -- print the error message in the log file
    Okl_Accounting_Util.get_error_message(g_error_msg);
    IF (g_error_msg.COUNT > 0) THEN
      FOR i IN g_error_msg.FIRST..g_error_msg.LAST
      LOOP
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, g_error_msg(i));
      END LOOP;
    END IF;  */

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;

    --close open cursors
    IF book_ctrl_trx_csr%ISOPEN THEN
      CLOSE book_ctrl_trx_csr;
    END IF;

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END exec_controller_prg2;

-----------------------------------------------------------------------------
-- PROCEDURE execute_qa_check_list
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : execute_qa_check_list
-- Description     : Procedure called from QA Validation concurrent request
--                   to execute QA Checklist
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE execute_qa_check_list(
     p_errbuf      OUT NOCOPY VARCHAR2,
     p_retcode     OUT NOCOPY NUMBER,
     p_khr_id      IN  okc_k_headers_b.id%TYPE) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'execute_qa_check_list';
  l_api_version      CONSTANT NUMBER := 1.0;
  p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_qcl_id           NUMBER;
  l_severity         fnd_lookups.meaning%TYPE;
  l_error_sts        VARCHAR2(1);
  l_msg_tbl          OKL_QA_CHECK_PUB.msg_tbl_type;
  l_data_len         NUMBER;
  l_msg_token_tbl    msg_token_tbl;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;
  l_qa_sts           VARCHAR2(1);

  --cursor to check if the contract has an assigned QA checker.
  --else default it to 1
  CURSOR get_qcl_id(p_khr_id  okc_k_headers_b.id%TYPE) IS
  SELECT NVL(qcl_id,1)
  FROM okc_k_headers_b
  WHERE id = p_khr_id;

  --cursor to fetch severity meaning
  CURSOR get_severity(p_sts_code  fnd_lookups.lookup_code%TYPE) IS
  SELECT meaning
  FROM fnd_lookups
  WHERE lookup_type = 'CP_SET_OUTCOME'
  AND lookup_code = p_sts_code;

BEGIN

  p_retcode := 0;
  --print OKL copyright in the output file
  l_msg_token_tbl(1).token_name := 'API_NAME';
  l_msg_token_tbl(1).token_value := 'OKLRBCTB.pls';
  l_msg_token_tbl(2).token_name := 'CONC_PROGRAM';
  l_msg_token_tbl(2).token_value := 'QA Validation';
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_COPYRIGHT_HEADER',l_msg_token_tbl));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_QACHECK_START')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_CONC_REQ_ID','REQUEST_ID',fnd_global.conc_request_id));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Activity Successful');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  --fetch qcl_id for the contract
  OPEN get_qcl_id(p_khr_id);
  FETCH get_qcl_id INTO l_qcl_id;
  IF get_qcl_id%NOTFOUND THEN
    --error : contract does not exist
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : Contract Number is not valid.');
    l_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  CLOSE get_qcl_id;

  --call QA validate program
  okl_contract_book_pub.execute_qa_check_list(
                           p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
                           p_qcl_id        => l_qcl_id,
                           p_chr_id        => p_khr_id,
                           x_msg_tbl       => l_msg_tbl);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to okl_contract_book_pub.execute_qa_check_list');
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'error in call to okl_contract_book_pub.execute_qa_check_list');
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --print QA validation checklist into the output file
  IF (l_msg_tbl.COUNT > 0) THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_QA_CHECKLIST'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '---------------------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    --column headings for the QA Validation checklist
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
        RPAD(OKL_ACCOUNTING_UTIL.GET_MESSAGE_TOKEN('OKL_LA_CONTRACT_QA', 'OKL_PROCESS'),40,' ')||
        RPAD(OKL_ACCOUNTING_UTIL.GET_MESSAGE_TOKEN('OKL_LA_CONTRACT_QA', 'OKL_DESCRIPTION'),40,' ')||
        RPAD(OKL_ACCOUNTING_UTIL.GET_MESSAGE_TOKEN('OKL_LA_CONTRACT_QA', 'OKL_SEVERITY'),9,' ')||
        RPAD(OKL_ACCOUNTING_UTIL.GET_MESSAGE_TOKEN('OKL_LA_CONTRACT_QA', 'OKL_EXPLANATION'),51,' '));

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=',140,'='));

    --loop to print QA validation checklist
    FOR i IN l_msg_tbl.FIRST..l_msg_tbl.LAST
    LOOP
      l_severity := null;
      --handle unexpected system error
      IF (l_msg_tbl(i).error_status = 'U') THEN
        l_error_sts := 'E';
      ELSE
        l_error_sts := l_msg_tbl(i).error_status;
      END IF;

      IF (l_qa_sts IS NULL AND l_error_sts = 'E') THEN
        l_qa_sts := 'E';
      END IF;

      --fetch severity meaning to be displayed in checklist
      OPEN get_severity(l_error_sts);
      FETCH get_severity INTO l_severity;
      IF get_severity%NOTFOUND THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : Invalid error status code '||l_error_sts);
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE get_severity;

      --printing checklist
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            RPAD(l_msg_tbl(i).name,40,' ')||
                            RPAD(l_msg_tbl(i).description,40,' ')||
                            RPAD(l_severity,9,' ')||
                            RPAD(l_msg_tbl(i).data,51,' '));

      l_data_len := 52;
      LOOP
        EXIT WHEN (SUBSTR(l_msg_tbl(i).data,l_data_len) IS NULL);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                              RPAD(' ',89,' ')||
                              RPAD(SUBSTR(l_msg_tbl(i).data,l_data_len),51,' '));

        l_data_len := l_data_len + 52;
        --condition to restrict explanation to 2000 characters
        --incase loop runs infinitely
        EXIT WHEN l_data_len > 2000;
      END LOOP;

    END LOOP;
  END IF; --finished printing QA checklist to output file.

  IF (l_qa_sts = 'E') THEN
    p_retcode := 2;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'QA validation completed successfully....');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Activity Successful');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_REQ_SUCCESS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_QACHECK_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;

    --close open cursors
    IF get_qcl_id%ISOPEN THEN
      CLOSE get_qcl_id;
    END IF;
    IF get_severity%ISOPEN THEN
      CLOSE get_severity;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    --print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_QACHECK_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;

    --close open cursors
    IF get_qcl_id%ISOPEN THEN
      CLOSE get_qcl_id;
    END IF;
    IF get_severity%ISOPEN THEN
      CLOSE get_severity;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_QACHECK_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;

    --close open cursors
    IF get_qcl_id%ISOPEN THEN
      CLOSE get_qcl_id;
    END IF;
    IF get_severity%ISOPEN THEN
      CLOSE get_severity;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OTHERS',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_QACHECK_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END execute_qa_check_list;


-----------------------------------------------------------------------------
-- PROCEDURE generate_streams
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : generate_streams
-- Description     : Procedure called from Stream Generation concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE generate_streams(
     p_errbuf      OUT NOCOPY VARCHAR2,
     p_retcode     OUT NOCOPY NUMBER,
     p_khr_id      IN  okc_k_headers_b.id%TYPE) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'generate_streams';
  l_api_version      CONSTANT NUMBER := 1.0;
  p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_pricing_engine   VARCHAR2(30);
  l_trx_number       NUMBER;
  x_trx_number       NUMBER;
  l_trx_status       VARCHAR2(30);
  l_sis_code         VARCHAR2(30);
  l_sts_code         VARCHAR2(30);
  l_msg_token_tbl    msg_token_tbl;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;

  --cursor to fetch the ESG transaction status
  CURSOR extr_strm_gen_status(p_trx_num NUMBER) IS
  SELECT sis_code
  FROM okl_stream_interfaces
  WHERE transaction_number = p_trx_num;

  --cursor to fetch the current contract status
  CURSOR get_contract_status(p_khr_id okc_k_headers_b.id%TYPE) IS
  SELECT sts_code
  FROM okc_k_headers_b
  WHERE id = p_khr_id;

  --cursor the fetch the ESG trx number and status for the contract
  CURSOR get_trx_number(p_khr_id okc_k_headers_b.id%TYPE) IS
  SELECT transaction_number, sis_code
  FROM okl_stream_interfaces
  WHERE khr_id = p_khr_id
  AND date_processed =
         (SELECT MAX(date_processed)
          FROM okl_stream_interfaces
          WHERE khr_id = p_khr_id
          AND sis_code NOT IN ('PROCESS_COMPLETE','PROCESS_COMPLETE_ERRORS',
              'PROCESSING_FAILED','TIME_OUT','PROCESS_ABORTED', 'SERVER_NA')
         );

BEGIN
  p_retcode := 0;
  --print OKL copyright in the output file
  l_msg_token_tbl(1).token_name := 'API_NAME';
  l_msg_token_tbl(1).token_value := 'OKLRBCTB.pls';
  l_msg_token_tbl(2).token_name := 'CONC_PROGRAM';
  l_msg_token_tbl(2).token_value := 'Stream Generation';
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_COPYRIGHT_HEADER',l_msg_token_tbl));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_STREAM_GENERATION_START')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_CONC_REQ_ID','REQUEST_ID',fnd_global.conc_request_id));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Activity Successful');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  --get the pricing engine set for the contract(ISG or ESG)
  okl_streams_util.get_pricing_engine(
                     p_khr_id         => p_khr_id,
                     x_pricing_engine => l_pricing_engine,
                     x_return_status  => l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in okl_stream_util.get_pricing_engine');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in okl_stream_util.get_pricing_engine');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_STREAM_GEN_METHOD','ST_GEN_METHOD',l_pricing_engine));

  --pricing engine is set to INTERNAL or EXTERNAL
  IF (l_pricing_engine  = 'INTERNAL' OR l_pricing_engine  = 'EXTERNAL') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call to Stream Generation');
    --call to Internal Stream Generation
    okl_contract_book_pvt.generate_streams(
                         p_api_version        => l_api_version,
                         p_init_msg_list      => l_init_msg_list,
                         p_chr_id             => p_khr_id,
                         p_generation_context => null,
                         x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data,
                         x_trx_number         => l_trx_number,
                         x_trx_status         => l_trx_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in okl_contract_book_pvt.generate_streams');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in okl_contract_book_pvt.generate_streams');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stream Generation failed. Pricing engine not set');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

    IF (l_pricing_engine  = 'EXTERNAL') THEN
        COMMIT;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_STREAM_TRX_ID','STREAM_TRX_ID',l_trx_number));
        --wait logic for ESG to complete..
        LOOP
          --fetch the transaction status for ESG
          OPEN extr_strm_gen_status(l_trx_number);
          FETCH extr_strm_gen_status INTO l_sis_code;
          IF extr_strm_gen_status%NOTFOUND THEN
            p_retcode := 2;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'No record found in okl_stream_interfaces for trx_number'||l_trx_number);
            EXIT;
          END IF;
          CLOSE extr_strm_gen_status;

          --fetch contract status
          OPEN get_contract_status(p_khr_id);
          FETCH get_contract_status INTO l_sts_code;
          IF get_contract_status%NOTFOUND THEN
            p_retcode := 2;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'No record found for contract_id'||p_khr_id);
            EXIT;
          END IF;
          CLOSE get_contract_status;

          --exit wait logic when ESG transaction completes successfully
          --and contract status is updated or when ESG transaction fails.
          EXIT WHEN((l_sis_code = 'PROCESS_COMPLETE' AND l_sts_code = 'COMPLETE') OR
                    l_sis_code IN ('PROCESS_COMPLETE_ERRORS','PROCESSING_FAILED',
                                       'TIME_OUT','PROCESS_ABORTED', 'SERVER_NA'));

          dbms_lock.sleep(10);
        END LOOP; --end of ESG wait logic

        --return concurrent request status as Error if ESG failed.
        IF (l_sis_code IN ('PROCESS_COMPLETE_ERRORS','PROCESSING_FAILED',
                           'TIME_OUT','PROCESS_ABORTED', 'SERVER_NA')) THEN
          p_retcode := 2;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stream Generation Not successful.'||l_sis_code);
        END IF;
    END IF;


  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stream Generation completed....');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Activity Successful');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_REQ_SUCCESS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_STREAM_GENERATION_SUCCESS')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;

    --close all open cursors
    IF extr_strm_gen_status%ISOPEN THEN
      CLOSE extr_strm_gen_status;
    END IF;
    IF get_contract_status%ISOPEN THEN
      CLOSE get_contract_status;
    END IF;
    IF get_trx_number%ISOPEN THEN
      CLOSE get_trx_number;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_STREAM_GENERATION_SUCCESS')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;

    --close all open cursors
    IF extr_strm_gen_status%ISOPEN THEN
      CLOSE extr_strm_gen_status;
    END IF;
    IF get_contract_status%ISOPEN THEN
      CLOSE get_contract_status;
    END IF;
    IF get_trx_number%ISOPEN THEN
      CLOSE get_trx_number;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_STREAM_GENERATION_SUCCESS')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;

    --close all open cursors
    IF extr_strm_gen_status%ISOPEN THEN
      CLOSE extr_strm_gen_status;
    END IF;
    IF get_contract_status%ISOPEN THEN
      CLOSE get_contract_status;
    END IF;
    IF get_trx_number%ISOPEN THEN
      CLOSE get_trx_number;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OTHERS',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_STREAM_GENERATION_SUCCESS')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END generate_streams;


-----------------------------------------------------------------------------
-- PROCEDURE generate_journal_entries
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : generate_journal_entries
-- Description     : Procedure called from Draft Journal Entry concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE generate_journal_entries(
     p_errbuf      OUT NOCOPY VARCHAR2,
     p_retcode     OUT NOCOPY NUMBER,
     p_khr_id      IN  okc_k_headers_b.id%TYPE) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'generate_journal_entries';
  l_api_version      CONSTANT NUMBER := 1.0;
  p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_orig_syst_code   okc_k_headers_b.orig_system_source_code%TYPE;
  l_orig_syst_id     okc_k_headers_b.orig_system_id1%TYPE;
  l_msg_token_tbl    msg_token_tbl;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;

  --cursor to fetch original system source code and id
  CURSOR orig_syst_csr(p_khr_id  okc_k_headers_b.id%TYPE) IS
  SELECT orig_system_source_code,
         orig_system_id1
  FROM okc_k_headers_v
  WHERE id = p_khr_id;

BEGIN
  p_retcode := 0;
  --print OKL copyright in the output file
  l_msg_token_tbl(1).token_name := 'API_NAME';
  l_msg_token_tbl(1).token_value := 'OKLRBCTB.pls';
  l_msg_token_tbl(2).token_name := 'CONC_PROGRAM';
  l_msg_token_tbl(2).token_value := 'Draft Journal Entry';
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_COPYRIGHT_HEADER',l_msg_token_tbl));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_JOURNAL_ENTRY_START')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_CONC_REQ_ID','REQUEST_ID',fnd_global.conc_request_id));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Activity Successful');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  --fetch orig_system_source_code and id
  OPEN orig_syst_csr(p_khr_id);
  FETCH orig_syst_csr INTO l_orig_syst_code,l_orig_syst_id;
  IF orig_syst_csr%NOTFOUND THEN
    --error : contract does not exist
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : Contract Number is not valid.');
    l_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  CLOSE orig_syst_csr;

  --if contract is in rebook process
  IF (l_orig_syst_code = 'OKL_REBOOK') THEN
    --call generate journal entries for rebook
    okl_contract_book_pub.generate_journal_entries(
                           p_api_version      => l_api_version,
                           p_init_msg_list    => l_init_msg_list,
                           p_commit           => 'Y',
                           p_contract_id      => l_orig_syst_id,
                           p_transaction_type => 'Rebook',
                           p_draft_yn         => 'T',
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to okl_contract_book_pub.generate_journal_entries');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in call to okl_contract_book_pub.generate_journal_entries');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  END IF; --end entries for rebook

  --call generate journal entries for Booking
  okl_contract_book_pub.generate_journal_entries(
                         p_api_version      => l_api_version,
                         p_init_msg_list    => l_init_msg_list,
                         p_commit           => 'Y',
                         p_contract_id      => p_khr_id,
                         p_transaction_type => 'Booking',
                         p_draft_yn         => 'T',
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to okl_contract_book_pub.generate_journal_entries');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in call to okl_contract_book_pub.generate_journal_entries');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Journal Entries generated successfully....');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Activity Successful');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_REQ_SUCCESS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_JOURNAL_ENTRY_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;

    --close open cursors
    IF orig_syst_csr%ISOPEN THEN
      CLOSE orig_syst_csr;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_JOURNAL_ENTRY_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;

    --close open cursors
    IF orig_syst_csr%ISOPEN THEN
      CLOSE orig_syst_csr;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_JOURNAL_ENTRY_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;

    --close open cursors
    IF orig_syst_csr%ISOPEN THEN
      CLOSE orig_syst_csr;
    END IF;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OTHERS',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_JOURNAL_ENTRY_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END generate_journal_entries;


-----------------------------------------------------------------------------
-- PROCEDURE submit_for_approval
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : submit_for_approval
-- Description     : Procedure called from Approval concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE submit_for_approval(
     p_errbuf      OUT NOCOPY VARCHAR2,
     p_retcode     OUT NOCOPY NUMBER,
     p_khr_id      IN  okc_k_headers_b.id%TYPE) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'submit_for_approval';
  l_api_version      CONSTANT NUMBER := 1.0;
  p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_msg_token_tbl    msg_token_tbl;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;

BEGIN
  p_retcode := 0;
  --print OKL copyright in the output file
  l_msg_token_tbl(1).token_name := 'API_NAME';
  l_msg_token_tbl(1).token_value := 'OKLRBCTB.pls';
  l_msg_token_tbl(2).token_name := 'CONC_PROGRAM';
  l_msg_token_tbl(2).token_value := 'Approval';
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_COPYRIGHT_HEADER',l_msg_token_tbl));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_APPROVAL_START')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_CONC_REQ_ID','REQUEST_ID',fnd_global.conc_request_id));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Activity Successful');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  --call program for contract approval
  okl_contract_book_pub.submit_for_approval(
                         p_api_version   => l_api_version,
                         p_init_msg_list => l_init_msg_list,
                         x_return_status => l_return_status,
                         x_msg_count     => l_msg_count,
                         x_msg_data      => l_msg_data,
                         p_chr_id        => p_khr_id);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to okl_contract_book_pub.submit_for_approval');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in call to okl_contract_book_pub.submit_for_approval');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Contract Approved successfully....');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Activity Successful');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_REQ_SUCCESS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_APPROVAL_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;
    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_APPROVAL_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;
    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_APPROVAL_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;
    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OTHERS',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_APPROVAL_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END submit_for_approval;

-----------------------------------------------------------------------------
-- PROCEDURE activate_contract
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : activate_contract
-- Description     : Procedure called from Activation concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE activate_contract(
     p_errbuf      OUT NOCOPY VARCHAR2,
     p_retcode     OUT NOCOPY NUMBER,
     p_khr_id      IN  okc_k_headers_b.id%TYPE) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'activate_contract';
  l_api_version      CONSTANT NUMBER := 1.0;
  p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_rem_amt          NUMBER;
  l_sts_code         okc_k_headers_b.sts_code%TYPE;
  l_qte_num          okl_trx_quotes_b.quote_number%TYPE;
  l_msg_token_tbl    msg_token_tbl;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;
  l_process_status   VARCHAR2(1);

BEGIN
  p_retcode := 0;
  --print OKL copyright in the output file
  l_msg_token_tbl(1).token_name := 'API_NAME';
  l_msg_token_tbl(1).token_value := 'OKLRBCTB.pls';
  l_msg_token_tbl(2).token_name := 'CONC_PROGRAM';
  l_msg_token_tbl(2).token_value := 'Activation';
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_COPYRIGHT_HEADER',l_msg_token_tbl));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_ACTIVATION_START')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_CONC_REQ_ID','REQUEST_ID',fnd_global.conc_request_id));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Activity Successful');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  --call program for contract activation
  okl_contract_book_pvt.approve_activate_contract(
                         p_api_version    => l_api_version,
                         p_init_msg_list  => l_init_msg_list,
                         x_return_status  => l_return_status,
                         x_msg_count      => l_msg_count,
                         x_msg_data       => l_msg_data,
                         p_chr_id         => p_khr_id,
                         x_process_status => l_process_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to okl_contract_book_pvt.approve_activate_contract');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in call to okl_contract_book_pvt.approve_activate_contract');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_process_status = OKL_API.G_RET_STS_ERROR OR l_process_status = OKL_API.G_RET_STS_WARNING) THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');
    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_ACTIVATION_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  END IF;

  IF (l_process_status <> OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Contract Activated successfully....');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_REQ_SUCCESS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_ACTIVATION_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  END IF;

  IF (l_process_status = OKL_API.G_RET_STS_ERROR) THEN
    p_retcode := 2;
  END IF;

  OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Activity Successful');


EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;
    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_ACTIVATION_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;
    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_ACTIVATION_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;
    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OTHERS',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CONTRACT_ACTIVATION_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END activate_contract;

-----------------------------------------------------------------------------
-- PROCEDURE init_book_controller_trx
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : init_book_controller_trx
-- Description     : Procedure to insert 4 records into OKL_BOOK_CONTROLLER_TRX
--                   Called from OKL_CONTRACT_BOOK_PVT.execute_qa_check_list
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE init_book_controller_trx(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE,
     x_batch_number        OUT NOCOPY NUMBER) IS

  l_api_name        CONSTANT VARCHAR2(30) := 'init_book_controller_trx';
  l_api_version     CONSTANT NUMBER := 1.0;
  l_batch_num       OKL_BOOK_CONTROLLER_TRX.BATCH_NUMBER%TYPE;
  l_bct_tbl         bct_tbl_type;
  lx_bct_tbl        bct_tbl_type;
  i                 NUMBER;

  --Cursor to check existence of contract trx records
  CURSOR c_book_ctrl_trx(p_khr_id IN NUMBER) IS
  SELECT 'Y'
  FROM   OKL_BOOK_CONTROLLER_TRX
  WHERE  khr_id = p_khr_id
  AND    NVL(active_flag,'N') = 'Y';

  --cursor to fetch the current status of the contract
  CURSOR get_curr_sts_code(p_khr_id  okc_k_headers_b.id%TYPE) IS
  SELECT sts_code
  FROM okc_k_headers_b
  WHERE id = p_khr_id;

  l_exists  VARCHAR2(1) DEFAULT 'N';
  l_curr_sts_code      okc_k_headers_b.sts_code%TYPE;
  l_qa_progress_status okl_book_controller_trx.progress_status%TYPE;
  l_ut_progress_status okl_book_controller_trx.progress_status%TYPE;
  l_st_progress_status okl_book_controller_trx.progress_status%TYPE;
  l_bk_progress_status okl_book_controller_trx.progress_status%TYPE;

BEGIN
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.init_book_controller_trx.', 'Begin(+)');
  END IF;

  x_batch_number  := null;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c_book_ctrl_trx(p_khr_id => p_khr_id);
  FETCH c_book_ctrl_trx INTO l_exists;
  CLOSE c_book_ctrl_trx;

  IF (l_exists = 'N') THEN
     --get new batch number from sequence
     l_batch_num := get_batch_id;
     IF(l_batch_num IS NULL OR l_batch_num = OKL_API.G_MISS_NUM) THEN
       --raise error if batch number could not be generated from seq.
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --fetch the current status of the contract
     OPEN get_curr_sts_code(p_khr_id);
     FETCH get_curr_sts_code INTO l_curr_sts_code;
     CLOSE get_curr_sts_code;

     IF (l_curr_sts_code = 'PASSED') THEN
         l_qa_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_ut_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_st_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING;
         l_bk_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING;
     ELSIF (l_curr_sts_code IN ('COMPLETE','APPROVED')) THEN
         l_qa_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_ut_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_st_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_bk_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING;
     ELSIF (l_curr_sts_code = 'PENDING_APPROVAL') THEN
         l_qa_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_ut_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_st_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_bk_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_RUNNING;
     --Bug# 9119881
     ELSIF (l_curr_sts_code IN ('NEW','INCOMPLETE')) THEN
         l_qa_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING;
         l_ut_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING;
         l_st_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING;
         l_bk_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING;
     ELSE
         l_qa_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_ut_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_st_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
         l_bk_progress_status := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
     END IF;
     --Bug# 9119881

      i := 0;
      --populate record for QA Validation
      i := i+1;
      l_bct_tbl(i) := populate_ctrl_trx_rec(
                        p_batch_num       => l_batch_num,
                        p_srl_num         => 10,
                        p_khr_id          => p_khr_id,
                        p_prog_name       => 'OKLBCTQA',
                        p_prog_short_name => 'OKLBCTQA',
                        p_progress_status => l_qa_progress_status,
                        p_active_flag     => 'Y');

    --populate record for Upfront Tax
    i := i+1;
    l_bct_tbl(i) := populate_ctrl_trx_rec(
                      p_batch_num       => l_batch_num,
                      p_srl_num         => 20,
                      p_khr_id          => p_khr_id,
                      p_prog_name       => 'OKLBCTUT',
                      p_prog_short_name => 'OKLBCTUT',
                      p_progress_status => l_ut_progress_status,
                      p_active_flag     => 'Y');

    --populate record for Price Contract
    i := i+1;
    l_bct_tbl(i) := populate_ctrl_trx_rec(
                      p_batch_num       => l_batch_num,
                      p_srl_num         => 30,
                      p_khr_id          => p_khr_id,
                      p_prog_name       => 'OKLBCTST',
                      p_prog_short_name => 'OKLBCTST',
                      p_progress_status => l_st_progress_status,
                      p_active_flag     => 'Y');

    --populate record for Activation
    i := i+1;
    l_bct_tbl(i) := populate_ctrl_trx_rec(
                      p_batch_num       => l_batch_num,
                      p_srl_num         => 40,
                      p_khr_id          => p_khr_id,
                      p_prog_name       => 'OKLBCTBK',
                      p_prog_short_name => 'OKLBCTBK',
                      p_progress_status => l_bk_progress_status,
                      p_active_flag     => 'Y');

    IF l_bct_tbl.COUNT > 0 THEN
    --insert records into controller tranasction table for the batch
      okl_bct_pvt.insert_row(
                   p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_bct_tbl       => l_bct_tbl,
                   x_bct_tbl       => lx_bct_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_batch_number := l_batch_num;

    END IF;

  END IF;


  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.init_book_controller_trx.', 'End(-)');
  END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.init_book_controller_trx.', 'EXP - ERROR');
     END IF;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.init_book_controller_trx.', 'EXP - UNEXCP ERROR');
     END IF;

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.init_book_controller_trx.', 'EXP - OTHERS');
     END IF;

END init_book_controller_trx;

-----------------------------------------------------------------------------
-- PROCEDURE update_book_controller_trx
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_book_controller_trx
-- Description     : Procedure to update status of records in OKL_BOOK_CONTROLLER_TRX table
--                   Called from OKL_CONTRACT_BOOK_PVT.execute_qa_check_list
-- Business Rules  :
-- Parameters      : p_khr_id p_prog_short_name p_progress_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE update_book_controller_trx(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE,
     p_prog_short_name     IN  okl_book_controller_trx.prog_short_name%TYPE,
     p_conc_req_id         IN  okl_book_controller_trx.conc_req_id%TYPE DEFAULT OKL_API.G_MISS_NUM,
     p_progress_status     IN  okl_book_controller_trx.progress_status%TYPE) IS

  l_api_name        CONSTANT VARCHAR2(30) := 'update_book_controller_trx';
  l_api_version     CONSTANT NUMBER := 1.0;
  l_bct_rec         bct_rec_type;
  x_bct_rec         bct_rec_type;

  CURSOR c_book_ctrl_trx(p_khr_id NUMBER,p_prog_short_name VARCHAR2) IS
  SELECT *
  FROM okl_book_controller_trx
  WHERE khr_id = p_khr_id
  AND   prog_short_name = nvl(p_prog_short_name, prog_short_name)
  AND   NVL(active_flag,'N') = 'Y';

  l_book_ctrl_trx c_book_ctrl_trx%ROWTYPE;

BEGIN
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx.', 'Begin(+)');
  END IF;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF (p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF (p_progress_status IS NULL OR p_progress_status = OKL_API.G_MISS_CHAR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c_book_ctrl_trx(p_khr_id,p_prog_short_name);
  LOOP
      FETCH c_book_ctrl_trx INTO l_book_ctrl_trx;
      EXIT WHEN c_book_ctrl_trx%NOTFOUND;
      l_bct_rec.user_id               := l_book_ctrl_trx.user_id;
      l_bct_rec.org_id                := l_book_ctrl_trx.org_id;
      l_bct_rec.batch_number          := l_book_ctrl_trx.batch_number;
      l_bct_rec.processing_srl_number := l_book_ctrl_trx.processing_srl_number;
      l_bct_rec.khr_id                := l_book_ctrl_trx.khr_id;
      l_bct_rec.program_name          := l_book_ctrl_trx.program_name;
      l_bct_rec.prog_short_name       := l_book_ctrl_trx.prog_short_name;
      IF (p_conc_req_id = OKL_API.G_MISS_NUM) THEN
         l_bct_rec.conc_req_id        := l_book_ctrl_trx.conc_req_id;
      ELSE
         l_bct_rec.conc_req_id        := p_conc_req_id;
      END IF;
      l_bct_rec.progress_status       := p_progress_status;
      l_bct_rec.active_flag           := l_book_ctrl_trx.active_flag;

      --call TAPI to update okl_book_controller_trx
      okl_bct_pvt.update_row(
                    p_api_version   => p_api_version,
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    p_bct_rec       => l_bct_rec,
                    x_bct_rec       => x_bct_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  END LOOP;
  CLOSE c_book_ctrl_trx;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx.', 'End(-)');
  END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF (c_book_ctrl_trx%ISOPEN) THEN
       CLOSE c_book_ctrl_trx;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx.', 'EXP - ERROR');
     END IF;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF (c_book_ctrl_trx%ISOPEN) THEN
       CLOSE c_book_ctrl_trx;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx.', 'EXP - UNEXCP ERROR');
     END IF;

  WHEN OTHERS THEN
    IF (c_book_ctrl_trx%ISOPEN) THEN
     CLOSE c_book_ctrl_trx;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx.', 'EXP - OTHERS');
     END IF;
END update_book_controller_trx;

-----------------------------------------------------------------------------
-- PROCEDURE cancel_contract_activation
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : cancel_contract_activation
-- Description     : Procedure to update status of contract header, line and records in okl_book_controller_trx table
--                   Called from Authoring UI
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE cancel_contract_activation(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'cancel_contract_activation';
  l_api_version     CONSTANT NUMBER := 1.0;
  l_prog_short_name OKL_BOOK_CONTROLLER_TRX.prog_short_name%TYPE;
BEGIN
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.cancel_contract_activation.', 'Begin(+)');
  END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  okl_contract_status_pub.update_contract_status(
                                           p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_khr_status    => 'INCOMPLETE',
                                           p_chr_id        => p_khr_id);
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  okl_contract_status_pub.cascade_lease_status
                (p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 p_chr_id          => p_khr_id);

  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  FOR i in 1..4
  LOOP
      IF (i = 1) THEN
         l_prog_short_name := OKL_BOOK_CONTROLLER_PVT.G_VALIDATE_CONTRACT;
      ELSIF (i = 2) THEN
         l_prog_short_name := OKL_BOOK_CONTROLLER_PVT.G_CALC_UPFRONT_TAX;
      ELSIF (i = 3) THEN
         l_prog_short_name := OKL_BOOK_CONTROLLER_PVT.G_PRICE_CONTRACT;
      ELSIF (i = 4) THEN
         l_prog_short_name := OKL_BOOK_CONTROLLER_PVT.G_SUBMIT_CONTRACT;
      END IF;

      okl_book_controller_pvt.update_book_controller_trx(
                                           p_api_version     => p_api_version,
                                           p_init_msg_list   => p_init_msg_list,
                                           x_return_status   => x_return_status,
                                           x_msg_count       => x_msg_count,
                                           x_msg_data        => x_msg_data,
                                           p_khr_id          => p_khr_id,
                                           p_prog_short_name => l_prog_short_name,
                                           p_conc_req_id     => NULL,
                                           p_progress_status => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   END LOOP;


  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.cancel_contract_activation.', 'End(-)');
  END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.cancel_contract_activation.', 'EXP - ERROR');
     END IF;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.cancel_contract_activation.', 'EXP - UNEXCP ERROR');
     END IF;

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.cancel_contract_activation.', 'EXP - OTHERS');
     END IF;
END cancel_contract_activation;

-----------------------------------------------------------------------------
-- PROCEDURE validate_contract_nxtbtn
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_contract_nxtbtn
-- Description     : Procedure to do validation when next button in validate
--                   contrtact page is clicked.
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE validate_contract_nxtbtn(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'validate_contract_nxtbtn';
  l_api_version     CONSTANT NUMBER := 1.0;

  CURSOR c_book_ctrl_trx(p_khr_id NUMBER,p_prog_short_name VARCHAR2) IS
  SELECT progress_status
  FROM okl_book_controller_trx
  WHERE khr_id = p_khr_id
  AND   prog_short_name = p_prog_short_name
  AND   NVL(active_flag,'N') = 'Y';

  l_progress_status okl_book_controller_trx.progress_status%TYPE;
  x_process_status  VARCHAR2(30);
BEGIN
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'Begin(+)');
  END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c_book_ctrl_trx(p_khr_id,okl_book_controller_pvt.g_validate_contract);
  FETCH c_book_ctrl_trx INTO l_progress_status;
  CLOSE c_book_ctrl_trx;

  IF (l_progress_status = okl_book_controller_pvt.g_prog_sts_complete) THEN
      OPEN c_book_ctrl_trx(p_khr_id,okl_book_controller_pvt.g_calc_upfront_tax);
      FETCH c_book_ctrl_trx INTO l_progress_status;
      CLOSE c_book_ctrl_trx;
      IF (l_progress_status = okl_book_controller_pvt.g_prog_sts_pending) THEN
          OKL_CONTRACT_BOOK_PVT.calculate_upfront_tax(
                          p_api_version      =>  p_api_version,
                          p_init_msg_list    =>  p_init_msg_list,
                          x_return_status    =>  x_return_status,
                          x_msg_count        =>  x_msg_count,
                          x_msg_data         =>  x_msg_data,
                          p_chr_id           =>  p_khr_id,
                          x_process_status   =>  x_process_status);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;

  ELSE
  -- The Contract must pass validation before upfront tax can be calculated.
     OKL_API.set_message(p_app_name => G_APP_NAME,
			 p_msg_name => 'OKL_LLA_NOT_VALIDATED');
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'End(-)');
  END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'EXP - ERROR');
     END IF;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'EXP - UNEXCP ERROR');
     END IF;

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'EXP - OTHERS');
     END IF;
END validate_contract_nxtbtn;

-----------------------------------------------------------------------------
-- PROCEDURE calc_upfronttax_nxtbtn
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : calc_upfronttax_nxtbtn
-- Description     : Procedure to do validation when next button in Upfront
--                   tax page is clicked.
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE calc_upfronttax_nxtbtn(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'calc_upfronttax_nxtbtn';
  l_api_version     CONSTANT NUMBER := 1.0;

  CURSOR c_book_ctrl_trx(p_khr_id NUMBER,p_prog_short_name VARCHAR2) IS
  SELECT progress_status
  FROM okl_book_controller_trx
  WHERE khr_id = p_khr_id
  AND   prog_short_name = p_prog_short_name
  AND   NVL(active_flag,'N') = 'Y';

  l_progress_status okl_book_controller_trx.progress_status%TYPE;
  x_process_status  VARCHAR2(30);
BEGIN
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.calc_upfronttax_nxtbtn.', 'Begin(+)');
  END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c_book_ctrl_trx(p_khr_id,okl_book_controller_pvt.g_calc_upfront_tax);
  FETCH c_book_ctrl_trx INTO l_progress_status;
  CLOSE c_book_ctrl_trx;

  IF (l_progress_status <> okl_book_controller_pvt.g_prog_sts_complete) THEN
     OKL_LA_SALES_TAX_PVT.validate_upfront_tax_fee(
            p_api_version     => p_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_chr_id          => p_khr_id);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
  END IF;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_BOOK_CONTROLLER_PVT.calc_upfronttax_nxtbtn.', 'End(-)');
  END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'EXP - ERROR');
     END IF;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'EXP - UNEXCP ERROR');
     END IF;

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_BOOK_CONTROLLER_PVT.validate_contract_nxtbtn.', 'EXP - OTHERS');
     END IF;
END calc_upfronttax_nxtbtn;

-----------------------------------------------------------------------------
-- PROCEDURE calculate_upfront_tax
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : calculate_upfront_tax
-- Description     : Procedure called from exec_controller_prg1
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE calculate_upfront_tax(
     p_errbuf      OUT NOCOPY VARCHAR2,
     p_retcode     OUT NOCOPY NUMBER,
     p_khr_id      IN  okc_k_headers_b.id%TYPE) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'calculate_upfront_tax';
  l_api_version      CONSTANT NUMBER := 1.0;
  p_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list    VARCHAR2(1) := 'T';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_msg_token_tbl    msg_token_tbl;
  l_data             VARCHAR2(2000);
  l_msg_index_out    NUMBER;
  l_process_status   VARCHAR2(1);


BEGIN
  p_retcode := 0;
  --print OKL copyright in the output file
  l_msg_token_tbl(1).token_name := 'API_NAME';
  l_msg_token_tbl(1).token_value := 'OKLRBCTB.pls';
  l_msg_token_tbl(2).token_name := 'CONC_PROGRAM';
  l_msg_token_tbl(2).token_value := 'Calculate Upfront Tax';
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_COPYRIGHT_HEADER',l_msg_token_tbl));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CALC_UPFRNTTX_START')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,get_message('OKL_CONC_REQ_ID','REQUEST_ID',fnd_global.conc_request_id));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,l_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Activity Successful');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  --call Upfront Tax for Booking
  okl_contract_book_pvt.calculate_upfront_tax(
                         p_api_version      => l_api_version,
                         p_init_msg_list    => l_init_msg_list,
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data,
                         p_chr_id           => p_khr_id,
                         x_process_status   => l_process_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in call to okl_contract_book_pvt.calculate_upfront_tax');
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in call to okl_contract_book_pvt.calculate_upfront_tax');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  IF (l_process_status = OKL_API.G_RET_STS_ERROR OR l_process_status = OKL_API.G_RET_STS_WARNING) THEN
    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
  END IF;

  IF (l_process_status <> OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Upfront Tax was calculated successfully....');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_REQ_SUCCESS'));
  END IF;

  IF (l_process_status = OKL_API.G_RET_STS_ERROR) THEN
    p_retcode := 2;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CALC_UPFRNTTX_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  OKL_API.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Activity Successful');

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    p_retcode := 2;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CALC_UPFRNTTX_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    p_retcode := 2;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CALC_UPFRNTTX_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;

    l_return_status := OKL_API.HANDLE_EXCEPTIONS(
          p_api_name  => l_api_name,
          p_pkg_name  => g_pkg_name,
          p_exc_name  => 'OTHERS',
          x_msg_count => l_msg_count,
          x_msg_data  => l_msg_data,
          p_api_type  => g_api_type);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_LLA_BOOK_STATUS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------');

    -- print the error message in the output file
    IF (fnd_msg_pub.count_msg > 0) THEN
      FOR l_counter IN 1 .. fnd_msg_pub.count_msg
      LOOP
        fnd_msg_pub.get(
                      p_msg_index     => l_counter,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_data);
      END LOOP;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CALC_UPFRNTTX_END')||' '||TO_CHAR(sysdate,'DD-MON-YYYY HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+--------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

END calculate_upfront_tax;

--Bug# 8798934
-----------------------------------------------------------------------------
-- FUNCTION is_prb_upgrade_required
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : is_prb_upgrade_required
-- Description     : Function called from Contract Activation Train -
--                   Price and Submit UI
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX rpillay Created
-- End of comments
FUNCTION is_prb_upgrade_required(
     p_khr_id              IN  NUMBER) RETURN VARCHAR2
IS

  l_prb_upgrade_required  VARCHAR2(1) := 'N';

  CURSOR l_chr_csr(p_khr_id IN NUMBER) IS
  SELECT chrb.orig_system_id1 orig_chr_id
  FROM   okc_k_headers_b chrb,
         okl_trx_contracts trx
  WHERE  chrb.id = p_khr_id
  AND    chrb.orig_system_source_code = 'OKL_REBOOK'
  AND    trx.khr_id_new = p_khr_id
  AND    trx.tcn_type = 'TRBK'
  AND    trx.tsu_code = 'ENTERED'
  AND    trx.representation_type = 'PRIMARY';

  CURSOR l_pricing_engine_csr(p_khr_id IN NUMBER) IS
  SELECT gts.pricing_engine
  FROM   okl_k_headers khr,
         okl_products pdt,
         okl_ae_tmpt_sets aes,
         okl_st_gen_tmpt_sets gts
  WHERE  khr.pdt_id = pdt.id
  AND    pdt.aes_id = aes.id
  AND    aes.gts_id = gts.id
  AND    khr.id     = p_khr_id;

  CURSOR l_acct_sys_opt_csr IS
  SELECT amort_inc_adj_rev_dt_yn
  FROM okl_sys_acct_opts;

  CURSOR l_chr_upg_csr(p_khr_id IN NUMBER) IS
  SELECT 'Y' chr_upgraded_yn
  FROM okl_stream_trx_data
  WHERE orig_khr_id = p_khr_id
  AND last_trx_state = 'Y';

  l_chr_rec            l_chr_csr%ROWTYPE;
  l_pricing_engine_rec l_pricing_engine_csr%ROWTYPE;
  l_acct_sys_opt_rec   l_acct_sys_opt_csr%ROWTYPE;
  l_chr_upgraded_yn    VARCHAR2(1);

BEGIN

  OPEN l_chr_csr(p_khr_id => p_khr_id);
  FETCH l_chr_csr INTO l_chr_rec;
  CLOSE l_chr_csr;

  IF (l_chr_rec.orig_chr_id IS NOT NULL) THEN

    OPEN l_acct_sys_opt_csr;
    FETCH l_acct_sys_opt_csr INTO l_acct_sys_opt_rec;
    CLOSE l_acct_sys_opt_csr;

    IF (NVL(l_acct_sys_opt_rec.amort_inc_adj_rev_dt_yn,'N') = 'Y') THEN

      OPEN l_pricing_engine_csr(l_chr_rec.orig_chr_id);
      FETCH l_pricing_engine_csr INTO l_pricing_engine_rec;
      CLOSE l_pricing_engine_csr;

      IF (l_pricing_engine_rec.pricing_engine = 'EXTERNAL') THEN

        l_chr_upgraded_yn := 'N';
        OPEN l_chr_upg_csr(p_khr_id => l_chr_rec.orig_chr_id);
        FETCH l_chr_upg_csr INTO l_chr_upgraded_yn;
        CLOSE l_chr_upg_csr;

        IF (NVL(l_chr_upgraded_yn,'N') = 'N') THEN

          l_prb_upgrade_required := 'Y';

        END IF;
      END IF;
    END IF;
  END IF;

  RETURN l_prb_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END is_prb_upgrade_required;

-----------------------------------------------------------------------------
-- PROCEDURE submit_prb_upgrade
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : submit_prb_upgrade
-- Description     : Procedure called from Upgrade button on
--                   Contract Activation Train - Price and Submit UI
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX rpillay Created
-- End of comments
PROCEDURE submit_prb_upgrade(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  NUMBER,
     x_request_numbers     OUT NOCOPY VARCHAR2) IS

  l_api_name        CONSTANT VARCHAR2(30) := 'submit_prb_upgrade';
  l_api_version     CONSTANT NUMBER := 1.0;

  CURSOR l_chk_upg_req_csr(p_khr_id IN NUMBER) IS
  SELECT 'Y' upg_req_exists_yn
  FROM okl_stream_interfaces
  WHERE khr_id = p_khr_id
  AND orp_code = 'UPGRADE'
  AND sis_code IN ('PROCESSING_REQUEST','PROCESS_COMPLETE_ERRORS','PROCESS_COMPLETE','RET_DATA_RECEIVED');

  CURSOR l_chr_csr(p_khr_id IN NUMBER) IS
  SELECT chrb_orig.id orig_chr_id,
         chrb_orig.contract_number
  FROM   okc_k_headers_b chrb_rbk,
         okc_k_headers_b chrb_orig,
         okl_trx_contracts trx
  WHERE  chrb_rbk.id = p_khr_id
  AND    chrb_rbk.orig_system_source_code = 'OKL_REBOOK'
  AND    chrb_orig.id = chrb_rbk.orig_system_id1
  AND    trx.khr_id = chrb_orig.id
  AND    trx.khr_id_new = p_khr_id
  AND    trx.tcn_type = 'TRBK'
  AND    trx.tsu_code = 'ENTERED'
  AND    trx.representation_type = 'PRIMARY';

  l_chr_rec           l_chr_csr%ROWTYPE;
  l_upg_req_exists_yn VARCHAR2(1);
  l_request_id        NUMBER;
  l_trans_status      VARCHAR2(100);
  l_rep_request_id    NUMBER;
  l_rep_trans_status  VARCHAR2(100);

  l_request_numbers_token VARCHAR2(1000);

BEGIN

  x_return_status   := OKL_API.G_RET_STS_SUCCESS;
  x_request_numbers := NULL;

  x_return_status := OKL_API.START_ACTIVITY(
                             p_api_name      => l_api_name,
                             p_pkg_name      => g_pkg_name,
                             p_init_msg_list => p_init_msg_list,
                             l_api_version   => l_api_version,
                             p_api_version   => p_api_version,
                             p_api_type      => g_api_type,
                             x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN l_chr_csr(p_khr_id => p_khr_id);
  FETCH l_chr_csr INTO l_chr_rec;
  CLOSE l_chr_csr;

  IF (l_chr_rec.orig_chr_id IS NOT NULL) THEN

    l_upg_req_exists_yn := 'N';
    OPEN l_chk_upg_req_csr(p_khr_id => l_chr_rec.orig_chr_id);
    FETCH l_chk_upg_req_csr INTO l_upg_req_exists_yn;
    CLOSE l_chk_upg_req_csr;

    IF (l_upg_req_exists_yn = 'Y') THEN

      OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_LLA_RBK_UPG_IN_PROG',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_chr_rec.contract_number);

      RAISE OKL_API.G_EXCEPTION_ERROR;

    ELSE
      -- establish the external_id values for the contracts, if they don't have one.
      OKL_LLA_UTIL_PVT.update_external_id(p_chr_id => l_chr_rec.orig_chr_id,
                                          x_return_status => x_return_status);

      IF x_return_status <> OKL_API.G_RET_STS_SUCCESS
      THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OKL_LA_STREAM_PVT.upgrade_esg_khr_for_prb(
        p_chr_id             => l_chr_rec.orig_chr_id
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       ,x_request_id         => l_request_id
       ,x_trans_status       => l_trans_status
       ,x_rep_request_id     => l_rep_request_id
       ,x_rep_trans_status   => l_rep_trans_status );

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        l_request_numbers_token := TO_CHAR(l_request_id);
        IF ( NVL(l_rep_request_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM ) THEN
          l_request_numbers_token := l_request_numbers_token || ', '|| TO_CHAR(l_rep_request_id);
        END IF;

        x_request_numbers := l_request_numbers_token;

      END IF;
    END IF;
  END IF;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                       x_msg_data  => x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

END submit_prb_upgrade;

--Bug# 8798934

END OKL_BOOK_CONTROLLER_PVT;

/
