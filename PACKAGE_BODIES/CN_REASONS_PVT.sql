--------------------------------------------------------
--  DDL for Package Body CN_REASONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_REASONS_PVT" AS
-- $Header: cnvresnb.pls 115.2 2002/11/21 21:16:49 hlchen ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_reasons_pvt
-- Purpose
--   Package Body to display the analyst comments for a payment worksheet.
-- History
--   04/02/02   Rao.Chenna         Created
   G_PKG_NAME                  	CONSTANT VARCHAR2(30) := 'CN_REASONS_PVT';
   G_FILE_NAME                 	CONSTANT VARCHAR2(12) := 'cnpresnb.pls';
--
/*
PROCEDURE my_debug(
   i_value		IN	VARCHAR2) IS
   l_error	VARCHAR2(1000);
BEGIN
   INSERT INTO cn_process_audit_lines(
   	process_audit_id,process_audit_line_id,
	message_type_code,message_text)
   VALUES(
        cn_process_audits_s.nextval,cn_process_audit_lines_s1.NEXTVAL,
	'cnnotes',i_value);
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      l_error := SQLERRM;
      INSERT INTO cn_process_audit_lines(
   	process_audit_id,process_audit_line_id,
	message_type_code,message_text)
      VALUES(
        cn_process_audits_s.nextval,cn_process_audit_lines_s1.NEXTVAL,
	'cnnotes',l_error);
      COMMIT;
END; */
--
PROCEDURE insert_row(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_reasons_all_rec 	IN 	CN_REASONS_PKG.REASONS_ALL_REC_TYPE,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'insert_row';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_reasons_all_rec	CN_REASONS_PKG.REASONS_ALL_REC_TYPE;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT insert_row;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   l_reasons_all_rec := p_reasons_all_rec;
   --
   BEGIN
      SELECT cn_reasons_s.NEXTVAL
        INTO l_reasons_all_rec.reason_id
	FROM DUAL;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE FND_API.G_EXC_ERROR;
   END;
   IF ((l_reasons_all_rec.reason_code = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.reason = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.lookup_type = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.updated_table = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.upd_table_id = fnd_api.g_miss_num)) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_REQUIRED_FIELDS');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_REQUIRED_FIELDS';
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      cn_reasons_pkg.insert_row(l_reasons_all_rec);
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_row;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_row;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO insert_row;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE update_row(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_reasons_all_rec 	IN 	CN_REASONS_PKG.REASONS_ALL_REC_TYPE,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   CURSOR reason_cur(l_reason_id NUMBER) IS
      SELECT *
        FROM cn_reasons r
       WHERE r.reason_id = l_reason_id;
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'update_row';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_reasons_all_rec	CN_REASONS_PKG.REASONS_ALL_REC_TYPE;
   l_history_rec	cn_reason_history_pkg.reason_history_all_rec_type;
   l_reason		VARCHAR2(4000);
   l_clob_loc		CLOB;
   l_clob_length	NUMBER;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_row;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   l_reasons_all_rec := p_reasons_all_rec;
   --
   IF ((l_reasons_all_rec.reason_code = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.reason = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.lookup_type = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.updated_table = fnd_api.g_miss_char) OR
       (l_reasons_all_rec.upd_table_id = fnd_api.g_miss_num)) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_REQUIRED_FIELDS');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_REQUIRED_FIELDS';
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      -- First original record to be moved to CN_REASON_HISTORY table.
      FOR rec IN reason_cur(l_reasons_all_rec.reason_id)
      LOOP
         l_history_rec.reason_id		:= rec.reason_id;
         l_history_rec.updated_table		:= rec.updated_table;
         l_history_rec.upd_table_id		:= rec.upd_table_id;
         l_history_rec.reason_code		:= rec.reason_code;
         l_history_rec.dml_flag			:= 'UPDATE';
         l_history_rec.lookup_type		:= rec.lookup_type;
         l_history_rec.update_flag		:= rec.lookup_type;
    	 l_history_rec.attribute_category	:= rec.attribute_category;
    	 l_history_rec.attribute1		:= rec.attribute1;
    	 l_history_rec.attribute2		:= rec.attribute2;
    	 l_history_rec.attribute3		:= rec.attribute3;
    	 l_history_rec.attribute4		:= rec.attribute4;
    	 l_history_rec.attribute5		:= rec.attribute5;
    	 l_history_rec.attribute6		:= rec.attribute6;
    	 l_history_rec.attribute7		:= rec.attribute7;
    	 l_history_rec.attribute8		:= rec.attribute8;
    	 l_history_rec.attribute9		:= rec.attribute9;
    	 l_history_rec.attribute10		:= rec.attribute10;
    	 l_history_rec.attribute11		:= rec.attribute11;
    	 l_history_rec.attribute12		:= rec.attribute12;
    	 l_history_rec.attribute13		:= rec.attribute13;
    	 l_history_rec.attribute14		:= rec.attribute14;
    	 l_history_rec.attribute15		:= rec.attribute15;
	 -- Processing CLOB
	 l_clob_loc := rec.reason;
	 l_clob_length := dbms_lob.getlength(l_clob_loc);
	 dbms_lob.read(l_clob_loc,l_clob_length,1,l_history_rec.reason);
	 -- End of CLOB processing
	 -- Get reason_history_id from the SEQUENCE.
	 SELECT cn_reason_history_s.NEXTVAL
	   INTO l_history_rec.reason_history_id
	   FROM dual;
	 --
	 cn_reason_history_pkg.insert_row(l_history_rec);
	 --
         cn_reasons_pkg.lock_update_row(l_reasons_all_rec);
	 --
      END LOOP;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_row;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_row;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_row;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE delete_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_reason_id		IN	NUMBER		:= FND_API.G_MISS_NUM,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   CURSOR reason_cur(l_reason_id NUMBER) IS
      SELECT *
        FROM cn_reasons r
       WHERE r.reason_id = l_reason_id;
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'delete_notes';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_history_rec	cn_reason_history_pkg.reason_history_all_rec_type;
   l_reason		VARCHAR2(4000);
   l_clob_loc		CLOB;
   l_clob_length	NUMBER;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT delete_notes;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   IF (p_reason_id = FND_API.G_MISS_NUM) THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_REASON_ID_ERROR');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_REASON_ID_ERROR';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- First original record to be moved to CN_REASON_HISTORY table.
   FOR rec IN reason_cur(p_reason_id)
   LOOP
      l_history_rec.reason_id		:= rec.reason_id;
      l_history_rec.updated_table	:= rec.updated_table;
      l_history_rec.upd_table_id	:= rec.upd_table_id;
      l_history_rec.reason_code		:= rec.reason_code;
      l_history_rec.dml_flag		:= 'DELETE';
      l_history_rec.lookup_type		:= rec.lookup_type;
      l_history_rec.update_flag		:= rec.lookup_type;
      l_history_rec.attribute_category	:= rec.attribute_category;
      l_history_rec.attribute1		:= rec.attribute1;
      l_history_rec.attribute2		:= rec.attribute2;
      l_history_rec.attribute3		:= rec.attribute3;
      l_history_rec.attribute4		:= rec.attribute4;
      l_history_rec.attribute5		:= rec.attribute5;
      l_history_rec.attribute6		:= rec.attribute6;
      l_history_rec.attribute7		:= rec.attribute7;
      l_history_rec.attribute8		:= rec.attribute8;
      l_history_rec.attribute9		:= rec.attribute9;
      l_history_rec.attribute10		:= rec.attribute10;
      l_history_rec.attribute11		:= rec.attribute11;
      l_history_rec.attribute12		:= rec.attribute12;
      l_history_rec.attribute13		:= rec.attribute13;
      l_history_rec.attribute14		:= rec.attribute14;
      l_history_rec.attribute15		:= rec.attribute15;
      -- Processing CLOB
      l_clob_loc := rec.reason;
      l_clob_length := dbms_lob.getlength(l_clob_loc);
      dbms_lob.read(l_clob_loc,l_clob_length,1,l_history_rec.reason);
      -- End of CLOB processing
      -- Get reason_history_id from the SEQUENCE.
      SELECT cn_reason_history_s.NEXTVAL
	INTO l_history_rec.reason_history_id
	FROM dual;
      --
      cn_reason_history_pkg.insert_row(l_history_rec);
      --
      cn_reasons_pkg.delete_row(p_reason_id);
      --
   END LOOP;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_row;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_row;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_row;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE delete_worksheet_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_payment_worksheet_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   CURSOR reason_cur IS
      SELECT reason_id
        FROM cn_reasons
       WHERE upd_table_id = p_payment_worksheet_id;
   --
   CURSOR history_cur IS
      SELECT reason_history_id
        FROM cn_reason_history
       WHERE upd_table_id = p_payment_worksheet_id;
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'delete_worksheet_notes';
   l_api_version      	CONSTANT NUMBER := 1.0;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT delete_worksheet_notes;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   IF (p_payment_worksheet_id = FND_API.G_MISS_NUM) THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_WORKSHEET_ID_ERROR');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_WORKSHEET_ID_ERROR';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   FOR history_rec IN history_cur
   LOOP
      cn_reason_history_pkg.delete_row(history_rec.reason_history_id);
   END LOOP;
   --
   FOR reason_rec IN reason_cur
   LOOP
      cn_reasons_pkg.delete_row(reason_rec.reason_id);
   END LOOP;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_worksheet_notes;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_worksheet_notes;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO delete_worksheet_notes;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
END;

/
