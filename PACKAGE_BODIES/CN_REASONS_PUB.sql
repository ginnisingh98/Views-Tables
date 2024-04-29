--------------------------------------------------------
--  DDL for Package Body CN_REASONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_REASONS_PUB" AS
-- $Header: cnpresnb.pls 115.3 2003/07/04 01:36:09 jjhuang ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_reasons_pub
-- Purpose
--   Package Body to display the analyst comments for a payment worksheet.
-- History
--   04/02/02   Rao.Chenna         Created
--   06/16/03   Julia Huang        Added show_last_analyst_note for 11.5.10
--
   G_PKG_NAME                  	CONSTANT VARCHAR2(30) := 'CN_REASONS_PUB';
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
PROCEDURE show_analyst_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_first			IN    	NUMBER,
   	p_last                  IN      NUMBER,
	p_payment_worksheet_id	IN	NUMBER,
	p_table_name		IN	VARCHAR2,
	p_lookup_type		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_worksheet_rec	 OUT NOCOPY cn_reasons_pub.worksheet_rec,
   	x_notes_tbl      OUT NOCOPY     cn_reasons_pub.notes_tbl,
   	x_notes_count    OUT NOCOPY     NUMBER) IS
   --
   CURSOR c1 IS
      SELECT w.payment_worksheet_id,w.role_id,w.worksheet_status,
             p.name,p.payrun_id,p.pay_period_id,p.status,
             ps.period_name,s.salesrep_id,s.resource_id,s.name,
             s.employee_number,pg.pay_group_id,pg.name
        FROM cn_payruns p,
             cn_payment_worksheets w,
             cn_salesreps s,
             cn_period_statuses ps,
             cn_pay_groups pg
       WHERE p.payrun_id = w.payrun_id
         AND w.salesrep_id = s.salesrep_id
         AND p.pay_period_id = ps.period_id
         AND pg.pay_group_id = p.pay_group_id
	 AND w.payment_worksheet_id = p_payment_worksheet_id;
   --
   CURSOR c2 IS
      SELECT r.*, u.user_name,l.meaning
        FROM cn_reasons r,fnd_user u,cn_lookups l
       WHERE upd_table_id 	= p_payment_worksheet_id
         AND r.lookup_type 	= p_lookup_type
	 AND updated_table 	= p_table_name
	 AND r.last_updated_by 	= u.user_id
	 AND r.reason_code 	= l.lookup_code
	 AND l.lookup_type 	= p_lookup_type
       ORDER BY r.last_update_date;
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'show_analyst_notes';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_worksheet_rec	cn_reasons_pub.worksheet_rec;
   l_tbl_count		NUMBER := 0;
   l_total_rows		NUMBER := 0;
   l_clob_loc		CLOB;
   l_clob_length	NUMBER;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT show_analyst_notes;
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
   -- Populate the worksheet information using this cursor and pass it to
   -- JSP
   OPEN c1;
   FETCH c1 INTO x_worksheet_rec;
   CLOSE c1;
   --
   -- Populate analyst notes.
   FOR rec IN c2
   LOOP
      l_total_rows := l_total_rows + 1;
      IF (l_total_rows BETWEEN p_first AND p_last) THEN
         l_tbl_count := l_tbl_count + 1;
         x_notes_tbl(l_tbl_count).reason_id		:= rec.reason_id;
         x_notes_tbl(l_tbl_count).updated_table		:= rec.updated_table;
         x_notes_tbl(l_tbl_count).upd_table_id		:= rec.upd_table_id;
         x_notes_tbl(l_tbl_count).reason_code		:= rec.reason_code;
	 x_notes_tbl(l_tbl_count).reason_meaning	:= rec.meaning;
         x_notes_tbl(l_tbl_count).lookup_type		:= rec.lookup_type;
	 x_notes_tbl(l_tbl_count).update_flag		:= rec.update_flag;
         x_notes_tbl(l_tbl_count).attribute_category	:= rec.attribute_category;
         x_notes_tbl(l_tbl_count).attribute1		:= rec.attribute1;
         x_notes_tbl(l_tbl_count).attribute2		:= rec.attribute2;
         x_notes_tbl(l_tbl_count).attribute3		:= rec.attribute3;
         x_notes_tbl(l_tbl_count).attribute4		:= rec.attribute4;
         x_notes_tbl(l_tbl_count).attribute5		:= rec.attribute5;
         x_notes_tbl(l_tbl_count).attribute6		:= rec.attribute6;
         x_notes_tbl(l_tbl_count).attribute7		:= rec.attribute7;
         x_notes_tbl(l_tbl_count).attribute8		:= rec.attribute8;
         x_notes_tbl(l_tbl_count).attribute9		:= rec.attribute9;
         x_notes_tbl(l_tbl_count).attribute10		:= rec.attribute10;
         x_notes_tbl(l_tbl_count).attribute11		:= rec.attribute11;
         x_notes_tbl(l_tbl_count).attribute12		:= rec.attribute12;
         x_notes_tbl(l_tbl_count).attribute13		:= rec.attribute13;
         x_notes_tbl(l_tbl_count).attribute14		:= rec.attribute14;
         x_notes_tbl(l_tbl_count).attribute15		:= rec.attribute15;
         x_notes_tbl(l_tbl_count).last_update_date	:= rec.last_update_date;
         x_notes_tbl(l_tbl_count).last_updated_by	:= rec.last_updated_by;
         x_notes_tbl(l_tbl_count).last_updated_username	:= rec.user_name;
         x_notes_tbl(l_tbl_count).object_version_number	:= rec.object_version_number;
	 -- Processing CLOB
	 l_clob_loc := rec.reason;
	 l_clob_length := dbms_lob.getlength(l_clob_loc);
	 dbms_lob.read(l_clob_loc,l_clob_length,1,x_notes_tbl(l_tbl_count).reason);
	 -- End of CLOB processing
      END IF;
   END LOOP;
   x_notes_count := l_total_rows;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO show_analyst_notes;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO show_analyst_notes;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO show_analyst_notes;
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
PROCEDURE manage_analyst_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_notes_tbl     	IN      cn_reasons_pub.notes_tbl,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'manage_analyst_notes';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_reasons_all_rec	CN_REASONS_PKG.REASONS_ALL_REC_TYPE;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT manage_analyst_notes;
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
   IF (p_notes_tbl.COUNT > 0) THEN
      FOR i IN p_notes_tbl.FIRST..p_notes_tbl.LAST
      LOOP
         --IF (p_notes_tbl(i).dml_flag = 'INSERT') THEN
	    IF ((p_notes_tbl(i).reason_code = 'SYSTEM_GENERATED') AND
	        (p_notes_tbl(i).lookup_type = 'ANALYST_NOTE_REASON')) THEN
	       l_reasons_all_rec.update_flag	:= 'N';
	    ELSE
	       l_reasons_all_rec.update_flag	:= 'Y';
	    END IF;
	    l_reasons_all_rec.reason_id		:= p_notes_tbl(i).reason_id;
            l_reasons_all_rec.updated_table	:= p_notes_tbl(i).updated_table;
            l_reasons_all_rec.upd_table_id	:= p_notes_tbl(i).upd_table_id;
            l_reasons_all_rec.reason_code	:= p_notes_tbl(i).reason_code;
	    l_reasons_all_rec.reason		:= p_notes_tbl(i).reason;
            l_reasons_all_rec.lookup_type	:= p_notes_tbl(i).lookup_type;
            l_reasons_all_rec.attribute_category:= p_notes_tbl(i).attribute_category;
            l_reasons_all_rec.attribute1	:= p_notes_tbl(i).attribute1;
            l_reasons_all_rec.attribute2	:= p_notes_tbl(i).attribute2;
            l_reasons_all_rec.attribute3	:= p_notes_tbl(i).attribute3;
            l_reasons_all_rec.attribute4	:= p_notes_tbl(i).attribute4;
            l_reasons_all_rec.attribute5	:= p_notes_tbl(i).attribute5;
            l_reasons_all_rec.attribute6	:= p_notes_tbl(i).attribute6;
            l_reasons_all_rec.attribute7	:= p_notes_tbl(i).attribute7;
            l_reasons_all_rec.attribute8	:= p_notes_tbl(i).attribute8;
            l_reasons_all_rec.attribute9	:= p_notes_tbl(i).attribute9;
            l_reasons_all_rec.attribute10	:= p_notes_tbl(i).attribute10;
            l_reasons_all_rec.attribute11	:= p_notes_tbl(i).attribute11;
            l_reasons_all_rec.attribute12	:= p_notes_tbl(i).attribute12;
            l_reasons_all_rec.attribute13	:= p_notes_tbl(i).attribute13;
            l_reasons_all_rec.attribute14	:= p_notes_tbl(i).attribute14;
            l_reasons_all_rec.attribute15	:= p_notes_tbl(i).attribute15;
	    l_reasons_all_rec.object_version_number:= p_notes_tbl(i).object_version_number;
	    --
	    IF (p_notes_tbl(i).dml_flag = 'INSERT') THEN
               cn_reasons_pvt.insert_row(
      		  p_api_version 	=> l_api_version,
		  p_init_msg_list	=> p_init_msg_list,
     		  p_validation_level	=> p_validation_level,
		  p_commit		=> p_commit,
		  p_reasons_all_rec	=> l_reasons_all_rec,
		  x_return_status	=> x_return_status,
		  x_msg_count		=> x_msg_count,
		  x_msg_data		=> x_msg_data,
		  x_loading_status	=> x_loading_status);
	    ELSIF (p_notes_tbl(i).dml_flag = 'UPDATE') THEN
               cn_reasons_pvt.update_row(
      		  p_api_version 	=> l_api_version,
		  p_init_msg_list	=> p_init_msg_list,
     		  p_validation_level	=> p_validation_level,
		  p_commit		=> p_commit,
		  p_reasons_all_rec	=> l_reasons_all_rec,
		  x_return_status	=> x_return_status,
		  x_msg_count		=> x_msg_count,
		  x_msg_data		=> x_msg_data,
		  x_loading_status	=> x_loading_status);
	    END IF;
	    --
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
	    --
	 --END IF;
      END LOOP;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO manage_analyst_notes;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO manage_analyst_notes;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO manage_analyst_notes;
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
PROCEDURE remove_analyst_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_payment_worksheet_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_reason_id		IN	NUMBER		:= FND_API.G_MISS_NUM,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS

   --
   l_api_name		CONSTANT VARCHAR2(30) := 'remove_analyst_notes';
   l_api_version      	CONSTANT NUMBER := 1.0;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT remove_analyst_notes;
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
   cn_reasons_pvt.delete_notes(
      	p_api_version 		=> l_api_version,
	p_init_msg_list		=> p_init_msg_list,
     	p_validation_level	=> p_validation_level,
	p_commit		=> p_commit,
	p_reason_id		=> p_reason_id,
	x_return_status		=> x_return_status,
	x_msg_count		=> x_msg_count,
	x_msg_data		=> x_msg_data,
	x_loading_status	=> x_loading_status);
   --
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO remove_analyst_notes;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO remove_analyst_notes;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO remove_analyst_notes;
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
--=====================================================================
--Procedure Name:show_last_analyst_note
--Description: Used to get the last analyst note and total number of notes.
--11.5.10
--=====================================================================
PROCEDURE show_last_analyst_note(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_payment_worksheet_id	IN	NUMBER,
	p_table_name		IN	VARCHAR2,
	p_lookup_type		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
   	x_notes_tbl      OUT NOCOPY     cn_reasons_pub.notes_tbl,
   	x_notes_count    OUT NOCOPY     NUMBER)
IS
    CURSOR get_notes_count(p_payment_worksheet_id cn_payment_worksheets.payment_worksheet_id%TYPE,
                            p_lookup_type cn_reasons.lookup_type%TYPE,
                            p_table_name cn_reasons.updated_table%TYPE)
    IS
        SELECT COUNT(1) cnt
        FROM cn_reasons r
        WHERE r.upd_table_id 	= p_payment_worksheet_id
        AND r.lookup_type 	= p_lookup_type
        AND r.updated_table 	= p_table_name;

    CURSOR get_notes_info(p_payment_worksheet_id cn_payment_worksheets.payment_worksheet_id%TYPE,
                            p_lookup_type cn_reasons.lookup_type%TYPE,
                            p_table_name cn_reasons.updated_table%TYPE)
    IS
        SELECT v.*
        FROM
        (
        SELECT r.*, u.user_name,l.meaning
        FROM cn_reasons r,fnd_user u,cn_lookups l
        WHERE upd_table_id 	= p_payment_worksheet_id
        AND r.lookup_type 	= p_lookup_type
        AND updated_table 	= p_table_name
        AND r.last_updated_by 	= u.user_id
        AND r.reason_code 	= l.lookup_code
        AND l.lookup_type 	= p_lookup_type
        ORDER BY r.last_update_date desc
        ) v
        WHERE ROWNUM < 2;
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'show_last_analyst_note';
   l_api_version      	CONSTANT NUMBER := 1.0;

   l_clob_loc		CLOB;
   l_clob_length	NUMBER;

   l_tbl_count      NUMBER := 0;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT show_last_analyst_note;
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

   --
   -- Populate the number of notes.
   FOR i IN get_notes_count(p_payment_worksheet_id, p_lookup_type, p_table_name)
   LOOP
        x_notes_count := i.cnt;
   END LOOP;

   --
   -- Populate the last analyst note.
   FOR rec IN get_notes_info(p_payment_worksheet_id, p_lookup_type, p_table_name)
   LOOP
         x_notes_tbl(l_tbl_count).reason_id		:= rec.reason_id;
         x_notes_tbl(l_tbl_count).updated_table		:= rec.updated_table;
         x_notes_tbl(l_tbl_count).upd_table_id		:= rec.upd_table_id;
         x_notes_tbl(l_tbl_count).reason_code		:= rec.reason_code;
	 x_notes_tbl(l_tbl_count).reason_meaning	:= rec.meaning;
         x_notes_tbl(l_tbl_count).lookup_type		:= rec.lookup_type;
	 x_notes_tbl(l_tbl_count).update_flag		:= rec.update_flag;
         x_notes_tbl(l_tbl_count).attribute_category	:= rec.attribute_category;
         x_notes_tbl(l_tbl_count).attribute1		:= rec.attribute1;
         x_notes_tbl(l_tbl_count).attribute2		:= rec.attribute2;
         x_notes_tbl(l_tbl_count).attribute3		:= rec.attribute3;
         x_notes_tbl(l_tbl_count).attribute4		:= rec.attribute4;
         x_notes_tbl(l_tbl_count).attribute5		:= rec.attribute5;
         x_notes_tbl(l_tbl_count).attribute6		:= rec.attribute6;
         x_notes_tbl(l_tbl_count).attribute7		:= rec.attribute7;
         x_notes_tbl(l_tbl_count).attribute8		:= rec.attribute8;
         x_notes_tbl(l_tbl_count).attribute9		:= rec.attribute9;
         x_notes_tbl(l_tbl_count).attribute10		:= rec.attribute10;
         x_notes_tbl(l_tbl_count).attribute11		:= rec.attribute11;
         x_notes_tbl(l_tbl_count).attribute12		:= rec.attribute12;
         x_notes_tbl(l_tbl_count).attribute13		:= rec.attribute13;
         x_notes_tbl(l_tbl_count).attribute14		:= rec.attribute14;
         x_notes_tbl(l_tbl_count).attribute15		:= rec.attribute15;
         x_notes_tbl(l_tbl_count).last_update_date	:= rec.last_update_date;
         x_notes_tbl(l_tbl_count).last_updated_by	:= rec.last_updated_by;
         x_notes_tbl(l_tbl_count).last_updated_username	:= rec.user_name;
         x_notes_tbl(l_tbl_count).object_version_number	:= rec.object_version_number;
	 -- Processing CLOB
	 l_clob_loc := rec.reason;
	 l_clob_length := dbms_lob.getlength(l_clob_loc);
	 dbms_lob.read(l_clob_loc,l_clob_length,1,x_notes_tbl(l_tbl_count).reason);
	 -- End of CLOB processing

        l_tbl_count := l_tbl_count + 1;
   END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO show_last_analyst_note;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO show_last_analyst_note;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO show_last_analyst_note;
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

END show_last_analyst_note;

END;

/
