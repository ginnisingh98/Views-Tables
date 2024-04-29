--------------------------------------------------------
--  DDL for Package Body IGS_DA_PURGE_RQST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_PURGE_RQST_PKG" AS
/* $Header: IGSDA11B.pls 120.1 2006/01/18 23:04:33 swaghmar noship $ */
/*******************************************************************************
  Change History:
  Who         When            What
  DDEY        31-March-2003
  1. Package Created for deleting the request by an Administrator and the
     Student.
  2. The Job is written to purge the Data, in the base tables based on the
     parameters passed.
*******************************************************************************/
  PROCEDURE delete_row (
    p_batch_id          IN NUMBER,
    x_status            OUT NOCOPY VARCHAR2
  ) IS
  /*****************************************************************************
    Created By:         Deepankar Dey
    Date Created By:    12-11-2001
    Purpose:
      This procedure is to be called from the SS screens, to delete the records
      corresponding to the
    Known limitations,enhancements,remarks:
    Change History
    Who        When        What
  *****************************************************************************/
    CURSOR cur_req_stdnts IS
      SELECT   ROWID
      FROM     igs_da_req_stdnts
      WHERE    batch_id = p_batch_id ;
    CURSOR cur_req_ftrs IS
      SELECT   ROWID
      FROM     igs_da_req_ftrs
      WHERE    batch_id = p_batch_id ;
    CURSOR cur_req_wifs IS
      SELECT   ROWID
      FROM     igs_da_req_wif
      WHERE    batch_id = p_batch_id ;
    CURSOR cur_req_rqst IS
      SELECT   ROWID
      FROM     igs_da_rqst
      WHERE    batch_id = p_batch_id ;
    --
    l_return_status VARCHAR2(1);
    l_msg_data VARCHAR2(2000);
    l_msg_count  NUMBER;
    --
  BEGIN
    --
    IF (p_batch_id IS NULL) THEN
      FND_MESSAGE.Set_Name ('IGS', 'IGS_DA_BTCH_ID_NOT_FND');
      FND_MESSAGE.Set_Token ('BATCH_ID', p_batch_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --
      FOR l_req_stdnts IN cur_req_stdnts LOOP
        igs_da_req_stdnts_pkg.delete_row (
          x_rowid                =>   l_req_stdnts.ROWID
        );
      END LOOP;
      --
      FOR l_req_ftrs IN cur_req_ftrs LOOP
        igs_da_req_ftrs_pkg.delete_row (
          x_rowid                => l_req_ftrs.ROWID,
          x_return_status        => l_return_status,
          x_msg_data             => l_msg_data,
          x_msg_count            => l_msg_count
        );
      END LOOP;
      --
      FOR l_req_wifs IN cur_req_wifs LOOP
        igs_da_req_wif_pkg.delete_row (
          x_rowid                => l_req_wifs.ROWID,
          x_return_status        => l_return_status,
          x_msg_data             => l_msg_data,
          x_msg_count            => l_msg_count
        );
      END LOOP;
      --
      FOR l_req_rqst IN cur_req_rqst LOOP
        igs_da_rqst_pkg.delete_row(
          x_rowid                => l_req_rqst.ROWID,
          x_return_status        => l_return_status,
          x_msg_data             => l_msg_data,
          x_msg_count            => l_msg_count
        );
      END LOOP;
      --
      x_status := 'S';
      --
    END IF ;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (cur_req_stdnts%ISOPEN) THEN
        CLOSE cur_req_stdnts;
      END IF;
      IF (cur_req_ftrs%ISOPEN) THEN
        CLOSE cur_req_ftrs;
      END IF;
      IF (cur_req_wifs%ISOPEN) THEN
        CLOSE cur_req_wifs;
      END IF;
      IF (cur_req_rqst%ISOPEN) THEN
        CLOSE cur_req_rqst;
      END IF;
      x_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (cur_req_stdnts%ISOPEN) THEN
        CLOSE cur_req_stdnts;
      END IF;
      IF (cur_req_ftrs%ISOPEN) THEN
        CLOSE cur_req_ftrs;
      END IF;
      IF (cur_req_wifs%ISOPEN) THEN
        CLOSE cur_req_wifs;
      END IF;
      IF (cur_req_rqst%ISOPEN) THEN
        CLOSE cur_req_rqst;
      END IF;
  END delete_row;
  --
  -- Purge Requests Job
  --
  PROCEDURE purge_request (
    errbuf                OUT NOCOPY VARCHAR2,
    retcode               OUT NOCOPY NUMBER,
    p_c_start_date        IN VARCHAR2,
    p_c_end_date          IN VARCHAR2,
    p_c_request_number    IN NUMBER,
    p_requestor_id        IN NUMBER,
    p_responsibility      IN VARCHAR2,
    p_request_status      IN VARCHAR2,
    p_request_type        IN VARCHAR2
  ) IS
  /*****************************************************************************
    Created By:         Deepankar Dey
    Date Created By:    12-11-2001
    Purpose:
      This procedure is used to purge the degree audit requests based on the
      parameters passed from the Degree Audit - Purge Requests concurrent job.
    Known limitations,enhancements,remarks:
    Change History
    Who       When        What
    kdande    15-May-2003 Changed the cursor cur_request to have a proper join
                          for Bug# 2955477
    swaghmar  16-Jan-2006 Bug# 4951054 - Added check for disabling UI's
  *****************************************************************************/
    CURSOR cur_request IS
     SELECT distinct dar.ROWID, dar.batch_id, dar.request_type_id,
       flv.meaning request_status_meaning,
       pbv1.full_name requestor_full_name,
       dar.creation_date,
       dar.requestor_id
  FROM igs_da_rqst dar,
       igs_pe_person_base_v pbv1,
       igs_da_cnfg dac,
       igs_da_cnfg_req_typ dacr,
       fnd_lookup_values_vl flv
 WHERE dacr.request_type_id = dar.request_type_id
   AND dacr.purgable_ind = 'Y'
   AND flv.lookup_type = 'IGS_DA_RQST_STATUS'
   AND flv.lookup_code = dar.request_status
   AND dar.batch_id = NVL(p_c_request_number, dar.batch_id)
   AND dar.requestor_id =  NVL(p_requestor_id, dar.requestor_id)
   AND dac.responsibility_name = NVL(p_responsibility,dac.responsibility_name)
   AND dar.request_status = NVL(p_request_status,dar.request_status)
   AND dacr.request_type =NVL(p_request_type,dacr.request_type)
   AND ((p_c_start_date IS NULL)OR ( p_c_start_date IS NOT NULL AND dar.creation_date >= fnd_date.canonical_to_date (p_c_start_date)))
   AND ((p_c_end_date IS NULL)OR ( p_c_end_date IS NOT NULL AND dar.creation_date <= fnd_date.canonical_to_date (p_c_end_date)))
   AND dar.requestor_id = pbv1.person_id
   AND dac.request_type_id(+) = dar.request_type_id ;

    --
    CURSOR cur_request_type (cp_request_type_id
                               igs_da_cnfg_req_typ.request_type_id%TYPE) IS
      SELECT   dacr.request_name,
               dacr.request_type_meaning,
               dacr.request_mode_meaning
      FROM     igs_da_cnfg_req_typ_v dacr
      WHERE    dacr.request_type_id = cp_request_type_id;
    --
    CURSOR cur_req_stdnts (cp_batch_id igs_da_rqst.batch_id%TYPE) IS
      SELECT   ROWID
      FROM     igs_da_req_stdnts
      WHERE    batch_id = cp_batch_id ;
    --
    CURSOR cur_req_ftrs (cp_batch_id igs_da_rqst.batch_id%TYPE) IS
      SELECT   ROWID
      FROM     igs_da_req_ftrs
      WHERE    batch_id = cp_batch_id ;
    --
    CURSOR cur_req_wifs (cp_batch_id igs_da_rqst.batch_id%TYPE) IS
      SELECT   ROWID
      FROM     igs_da_req_wif
      WHERE    batch_id = cp_batch_id ;
    --
    l_return_status VARCHAR2(2000);
    l_msg_data VARCHAR2(2000);
    l_msg_count  NUMBER;
    p_start_date DATE;
    p_end_date DATE;
    l_count NUMBER := 0;
    l_cur_request_type cur_request_type%ROWTYPE;
    --
  BEGIN
    --

    retcode := 0;
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

    SAVEPOINT s_before_delete;
    --
    -- Putting Messages in the Log File
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_JOB');
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_START_DT');
    FND_MESSAGE.SET_TOKEN('START',p_c_start_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_END_DT');
    FND_MESSAGE.SET_TOKEN('END',p_c_end_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_REQ_NUM');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_c_request_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_REQUESTER');
    FND_MESSAGE.SET_TOKEN('REQ',p_requestor_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_RESP');
    FND_MESSAGE.SET_TOKEN('RESP',p_responsibility);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_REQ_STATUS');
    FND_MESSAGE.SET_TOKEN('REQ',p_request_status);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_MESSAGE.Set_Name('IGS','IGS_DA_REQ_TYPE');
    FND_MESSAGE.SET_TOKEN('REQ',p_request_type);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
    --
    FND_FILE.PUT_LINE(FND_FILE.LOG, '');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '');
    --
    IF (p_c_start_date IS NULL AND
        p_c_end_date IS NULL AND
        p_c_request_number IS NULL AND
        p_requestor_id IS NULL AND
        p_responsibility IS NULL AND
        p_request_status IS NULL AND
        p_request_type IS NULL) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --
      FOR l_cur_request IN cur_request LOOP
        FOR l_cur_req_stdnts IN cur_req_stdnts (l_cur_request.batch_id) LOOP
          --
          -- Deleting records from Request Students Interface table
          --
          igs_da_req_stdnts_pkg.delete_row (
            x_rowid =>   l_cur_req_stdnts.ROWID
          );
        END LOOP;
        --
        FOR l_cur_req_ftrs IN cur_req_ftrs(l_cur_request.batch_id) LOOP
          --
          -- Deleting records from Request Feature Interface table
          --
          igs_da_req_ftrs_pkg.delete_row (
            x_rowid                => l_cur_req_ftrs.ROWID,
            x_return_status        => l_return_status,
            x_msg_data             => l_msg_data,
            x_msg_count            => l_msg_count
          );
        END LOOP;
        --
        FOR l_cur_req_wifs IN cur_req_wifs(l_cur_request.batch_id) LOOP
          --
          -- Deleting records from WIF Interface table
          --
          igs_da_req_wif_pkg.delete_row (
            x_rowid                => l_cur_req_wifs.ROWID,
            x_return_status        => l_return_status,
            x_msg_data             => l_msg_data,
            x_msg_count            => l_msg_count
          );
          --
        END LOOP;
        --
        -- Putting Messages in the Log File
        --
        OPEN cur_request_type(l_cur_request.request_type_id);
        FETCH cur_request_type  INTO l_cur_request_type;
        CLOSE cur_request_type;
        --
        FND_MESSAGE.Set_Name('IGS','IGS_DA_BATCH_ID');
        FND_MESSAGE.SET_TOKEN('BATCH_ID',l_cur_request.batch_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
        --
        FND_MESSAGE.Set_Name('IGS','IGS_DA_REP_NAME');
        FND_MESSAGE.SET_TOKEN('REP',l_cur_request_type.request_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
        --
        FND_MESSAGE.Set_Name('IGS','IGS_DA_REQ_TYPE');
        FND_MESSAGE.SET_TOKEN('REQ',l_cur_request_type.request_type_meaning);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
        --
        FND_MESSAGE.Set_Name('IGS','IGS_DA_SEL_MODE');
        FND_MESSAGE.SET_TOKEN('SEL',l_cur_request_type.request_mode_meaning);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
        --
        FND_MESSAGE.Set_Name('IGS','IGS_DA_REQ_STATUS');
        FND_MESSAGE.SET_TOKEN('REQ',l_cur_request.request_status_meaning);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
        --
        FND_MESSAGE.Set_Name('IGS','IGS_DA_REQUESTER');
        FND_MESSAGE.SET_TOKEN('REQ',l_cur_request.requestor_full_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
        --
        FND_MESSAGE.Set_Name('IGS','IGS_DA_REQ_DT');
        FND_MESSAGE.SET_TOKEN('REQ',l_cur_request.creation_date);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
        --
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');
        --
        -- Incrementing the Processing Record Counter
        --
        l_count := l_count + 1;
        --
        -- Deleting records from Requests Interface table
        igs_da_rqst_pkg.delete_row(
          x_rowid                => l_cur_request.rowid,
          x_return_status        => l_return_status,
          x_msg_data             => l_msg_data,
          x_msg_count            => l_msg_count
        );
      END LOOP;
    END IF;
    --
    FND_MESSAGE.Set_Name ('IGS', 'IGS_DA_TOTAL_REQ');
    FND_MESSAGE.SET_TOKEN ('COUNT', l_count);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.Get);
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_DA_NO_PARAM');
      retcode := 2;
      ROLLBACK TO s_before_delete;
    WHEN OTHERS THEN
      ROLLBACK TO s_before_delete;
      errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      retcode := 2;
      FND_MESSAGE.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      FND_MESSAGE.SET_TOKEN ('NAME', 'igs_da_purge_rqst_pkg.purge_request(): '
                             || SUBSTR (SQLERRM,1,80));
      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.Get);
      IGS_GE_MSG_STACK.ADD;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END purge_request;
END igs_da_purge_rqst_pkg;

/
