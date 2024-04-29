--------------------------------------------------------
--  DDL for Package Body GL_COA_SEG_VAL_IMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_COA_SEG_VAL_IMP_PUB" AS
/* $Header: GLSVIPBB.pls 120.3.12010000.1 2009/12/16 11:52:27 sommukhe noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'gl_coa_seg_val_imp_pub';

PROCEDURE coa_segment_val_imp (
p_api_version			      IN           NUMBER,
p_init_msg_list			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_commit			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_validation_level		      IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
x_return_status			      OUT NOCOPY   VARCHAR2,
x_msg_count			      OUT NOCOPY   NUMBER,
x_msg_data			      OUT NOCOPY   VARCHAR2,
p_gl_flex_values_obj_tbl	      IN OUT NOCOPY GL_FLEX_VALUES_OBJ_TBL,
p_gl_flex_values_nh_obj_tbl           IN OUT NOCOPY GL_FLEX_VALUES_NH_OBJ_TBL,
p_gl_flex_values_status		      OUT NOCOPY VARCHAR2,
p_gl_flex_values_nh_status	      OUT NOCOPY VARCHAR2

 )  AS
/***********************************************************************************************
Created By:         Somnath Mukherjee
Date Created By:    01-AUG-2008
Purpose:            This is a public API to import data from external system to GL.
Known limitations,enhancements,remarks:

Change History

Who         When           What
VGATTU	   28-NOV-08	 Submitting the CP "Program - Inherit Segment Value Attributes"
***********************************************************************************************/
l_gl_flex_values_tbl  gl_coa_seg_val_imp_pub.gl_flex_values_tbl_type;
l_gl_flex_values_nh_tbl gl_coa_seg_val_imp_pub.gl_flex_values_nh_tbl_type;

l_api_name      CONSTANT VARCHAR2(30) := 'coa_segment_val_imp';
l_api_version   CONSTANT NUMBER := 1.0;
l_err_msg VARCHAR2(2000);
l_appl_name       VARCHAR2(30);
l_c_msg_name      fnd_new_messages.message_name%TYPE;
l_n_msg_num       fnd_new_messages.message_number%TYPE;
l_c_msg_txt       fnd_new_messages.message_text%TYPE;
l_user_id	NUMBER;
l_resp_id	NUMBER;
l_apps_id	NUMBER;
l_acc_set_id	NUMBER;
l_req_id	NUMBER;

PROCEDURE get_message(p_c_msg_name VARCHAR2,p_n_msg_num OUT NOCOPY NUMBER,p_c_msg_txt OUT NOCOPY VARCHAR2) AS
CURSOR c_msg(cp_c_msg_name fnd_new_messages.message_name%TYPE ) IS
 SELECT
   message_number,
   message_text
 FROM   fnd_new_messages
 WHERE  application_id=101
 AND    language_code = USERENV('LANG')
 AND    message_name=cp_c_msg_name;

 rec_c_msg         c_msg%ROWTYPE;
BEGIN
OPEN c_msg(p_c_msg_name);
FETCH c_msg INTO rec_c_msg;
IF c_msg%FOUND THEN
 p_n_msg_num := rec_c_msg.message_number;
 p_c_msg_txt := rec_c_msg.message_text;
ELSE
 p_c_msg_txt := p_c_msg_name;
END IF;
CLOSE c_msg;
END get_message;

/* Get message from Message Stack */

FUNCTION get_msg_from_stack(l_n_msg_count NUMBER) RETURN VARCHAR2 AS
l_c_msg VARCHAR2(3000);
l_c_msg_name fnd_new_messages.message_name%TYPE;
BEGIN
l_c_msg := FND_MSG_PUB.GET(p_msg_index => l_n_msg_count, p_encoded => 'T');
FND_MESSAGE.SET_ENCODED (l_c_msg);
FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_appl_name, l_c_msg_name);
RETURN l_c_msg_name;
END get_msg_from_stack;

BEGIN


  --Standard start of API savepoint
  SAVEPOINT coa_segment_val_imp_pub;

  --Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version ,
                                     p_api_version ,
                                     l_api_name    ,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

   IF p_gl_flex_values_obj_tbl IS NOT NULL AND p_gl_flex_values_obj_tbl.COUNT > 0 THEN
     FOR I in 1..p_gl_flex_values_obj_tbl.LAST LOOP
      IF p_gl_flex_values_obj_tbl.EXISTS(I) THEN
	l_gl_flex_values_tbl(I).value_set_name:=	p_gl_flex_values_obj_tbl(I).value_set_name;
	l_gl_flex_values_tbl(I).flex_value:=	p_gl_flex_values_obj_tbl(I).flex_value;
	l_gl_flex_values_tbl(I).flex_desc:= 	p_gl_flex_values_obj_tbl(I).flex_desc;
	l_gl_flex_values_tbl(I).parent_flex_value:=	p_gl_flex_values_obj_tbl(I).parent_flex_value;
	l_gl_flex_values_tbl(I).summary_flag:= 	p_gl_flex_values_obj_tbl(I).summary_flag;
	l_gl_flex_values_tbl(I).roll_up_group:=	p_gl_flex_values_obj_tbl(I).roll_up_group;
	l_gl_flex_values_tbl(I).hierarchy_level:=	p_gl_flex_values_obj_tbl(I).hierarchy_level;
	l_gl_flex_values_tbl(I).allow_budgeting:=	p_gl_flex_values_obj_tbl(I).allow_budgeting;
	l_gl_flex_values_tbl(I).allow_posting:=	p_gl_flex_values_obj_tbl(I).allow_posting;
	l_gl_flex_values_tbl(I).account_type:= 	p_gl_flex_values_obj_tbl(I).account_type;
	l_gl_flex_values_tbl(I).reconcile:= 	p_gl_flex_values_obj_tbl(I).reconcile;
	l_gl_flex_values_tbl(I).third_party_control_account:=	p_gl_flex_values_obj_tbl(I).third_party_control_account;
	l_gl_flex_values_tbl(I).enabled_flag:= 	p_gl_flex_values_obj_tbl(I).enabled_flag;
	l_gl_flex_values_tbl(I).effective_from:= 	p_gl_flex_values_obj_tbl(I).effective_from;
	l_gl_flex_values_tbl(I).effective_to:= 	p_gl_flex_values_obj_tbl(I).effective_to;
       END IF;
     END LOOP;
   END IF;


   IF p_gl_flex_values_nh_obj_tbl IS NOT NULL AND p_gl_flex_values_nh_obj_tbl.COUNT > 0 THEN
     FOR I in 1..p_gl_flex_values_nh_obj_tbl.LAST LOOP
       IF p_gl_flex_values_nh_obj_tbl.EXISTS(I) THEN
	 l_gl_flex_values_nh_tbl(I).value_set_name := p_gl_flex_values_nh_obj_tbl(I).value_set_name;
	 l_gl_flex_values_nh_tbl(I).parent_flex_value := p_gl_flex_values_nh_obj_tbl(I).parent_flex_value;
	 l_gl_flex_values_nh_tbl(I).range_attribute := p_gl_flex_values_nh_obj_tbl(I).range_attribute;
	 l_gl_flex_values_nh_tbl(I).child_flex_value_low := p_gl_flex_values_nh_obj_tbl(I).child_flex_value_low;
	 l_gl_flex_values_nh_tbl(I).child_flex_value_high := p_gl_flex_values_nh_obj_tbl(I).child_flex_value_high;
       END IF;
     END LOOP;
   END IF;

  --API body
     --Call the COA Segment Values import Private API
    gl_coa_segment_val_pvt.coa_segment_val_imp
    (
      p_api_version                   => p_api_version,
      p_init_msg_list                 => p_init_msg_list,
      p_commit                        => p_commit,
      p_validation_level              => p_validation_level,
      x_return_status	              => x_return_status,
      x_msg_count	              => x_msg_count,
      x_msg_data	              => x_msg_data,
      p_gl_flex_values_tbl	      => l_gl_flex_values_tbl,
      p_gl_flex_values_nh_tbl	      => l_gl_flex_values_nh_tbl,
      p_gl_flex_values_status	      => p_gl_flex_values_status,
      p_gl_flex_values_nh_status      => p_gl_flex_values_nh_status
     );

     IF l_gl_flex_values_tbl.COUNT > 0 THEN
       FOR I in 1..l_gl_flex_values_tbl.LAST LOOP
	  IF l_gl_flex_values_tbl.EXISTS(I) THEN
	    p_gl_flex_values_obj_tbl(I).status := l_gl_flex_values_tbl(I).status;
	  END IF;
       END LOOP;
     END IF;

     IF l_gl_flex_values_nh_tbl.COUNT > 0 THEN
       FOR I in 1..l_gl_flex_values_nh_tbl.LAST LOOP
	 IF l_gl_flex_values_nh_tbl.EXISTS(I) THEN
	   p_gl_flex_values_nh_obj_tbl(I).status := l_gl_flex_values_nh_tbl(I).status;
	 END IF;
       END LOOP;
     END IF;

     --Populate the x_msg_data
     --get the error messages from stack for l_gl_flex_values_tbl
     IF x_return_status = 'E' THEN
       l_err_msg:= NULL;
       x_msg_data := x_msg_data || 'Start of error messages for Import of Segment values'||FND_GLOBAL.newline;
       IF l_gl_flex_values_tbl.COUNT > 0 THEN
	 FOR i IN 1..l_gl_flex_values_tbl.LAST
	 LOOP
	   IF l_gl_flex_values_tbl.EXISTS(I) THEN
	     IF l_gl_flex_values_tbl(i).status = 'E' THEN
	       l_err_msg := l_err_msg || 'Error for '|| l_gl_flex_values_tbl(I).value_set_name ||
			    'AND' || l_gl_flex_values_tbl(I).flex_value || FND_GLOBAL.newline;
	       FOR l_curr_num IN l_gl_flex_values_tbl(i).msg_from..l_gl_flex_values_tbl(i).msg_to
	       LOOP
		 l_c_msg_name := get_msg_from_stack(l_curr_num);
		 get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
		 l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');
		 l_err_msg := l_err_msg || 'Message No. '|| I ||' ' || l_c_msg_txt;
		 IF length(l_err_msg) + length(x_msg_data) < 32000 THEN
		   x_msg_data := x_msg_data ||l_err_msg||FND_GLOBAL.newline;
		 END IF;
	       END LOOP;
	       l_err_msg:= NULL;
	     END IF;
	   END IF;
	  END LOOP;
	END IF;
      END IF;

     --get the error messages from stack for l_gl_flex_values_nh_tbl
     IF x_return_status = 'E' THEN
       l_err_msg:= NULL;
       x_msg_data := x_msg_data || 'Start of error messages for Import of child ranges for parent values'||FND_GLOBAL.newline;
       IF l_gl_flex_values_nh_tbl.COUNT > 0 THEN
	 FOR i IN 1..l_gl_flex_values_nh_tbl.LAST
	 LOOP
	   IF l_gl_flex_values_tbl.EXISTS(I) THEN
	     IF l_gl_flex_values_nh_tbl(i).status = 'E' THEN
	       l_err_msg := l_err_msg || 'Error for '|| l_gl_flex_values_nh_tbl(I).value_set_name ||
			    'AND '|| l_gl_flex_values_nh_tbl(I).parent_flex_value ||
			    'AND '|| l_gl_flex_values_nh_tbl(I).range_attribute ||
			    'AND '|| l_gl_flex_values_nh_tbl(I).child_flex_value_low ||
			    'AND '|| l_gl_flex_values_nh_tbl(I).child_flex_value_high || FND_GLOBAL.newline;
	       FOR l_curr_num IN l_gl_flex_values_nh_tbl(i).msg_from..l_gl_flex_values_nh_tbl(i).msg_to
	       LOOP
		 l_c_msg_name := get_msg_from_stack(l_curr_num);
		 get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
		 l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');
		 l_err_msg := l_err_msg || 'Message No. '|| I ||' ' || l_c_msg_txt;
		 IF length(l_err_msg) + length(x_msg_data) < 32000 THEN
		   x_msg_data := x_msg_data ||l_err_msg||FND_GLOBAL.newline;
		 END IF;
	       END LOOP;
	       l_err_msg:= NULL;
	     END IF;
	   END IF;
	  END LOOP;
	END IF;
      END IF;

      l_user_id := fnd_global.user_id;
      l_resp_id := fnd_global.resp_id;
      l_apps_id := fnd_global.resp_appl_id;
      fnd_global.apps_initialize (l_user_id, l_resp_id, l_apps_id);
      fnd_profile.get('GL_ACCESS_SET_ID', l_acc_set_id);
      --Submit the Request for "Program - Inherit Segment Value Attributes"
      l_req_id :=fnd_request.submit_request('SQLGL', 'GLNSVI', '', '', FALSE,l_acc_set_id,'Y',
					     CHR(0), '', '', '', '', '', '',
					     '', '', '', '', '', '', '', '', '', '',
	                                     '', '', '', '', '', '', '', '', '', '',
	                                     '', '', '', '', '', '', '', '', '', '',
	                                     '', '', '', '', '', '', '', '', '', '',
	                                     '', '', '', '', '', '', '', '', '', '',
	                                     '', '', '', '', '', '', '', '', '', '',
	                                     '', '', '', '', '', '', '', '', '', '',
	                                     '', '', '', '', '', '', '', '', '', '',
		                             '', '', '', '', '', '', '', '', '', '',
			                     '');
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pub.coa_segment_val_imp.Triggered_GLNSVI',
	    'l_acc_set_id:'||TO_CHAR(l_acc_set_id)||'  '||'Request id:'||l_req_id);
      END IF;

      IF (l_req_id = 0) THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pub.coa_segment_val_imp.Error_in_GLNSVI',
	    'l_acc_set_id:'||TO_CHAR(l_acc_set_id)||'  '||'Error_Message:'||FND_MESSAGE.GET);
         END IF;
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO coa_segment_val_imp_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO coa_segment_val_imp_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO coa_segment_val_imp_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                   l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );

END coa_segment_val_imp;

END gl_coa_seg_val_imp_pub;

/
