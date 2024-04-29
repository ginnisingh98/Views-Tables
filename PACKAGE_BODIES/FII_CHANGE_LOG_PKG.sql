--------------------------------------------------------
--  DDL for Package Body FII_CHANGE_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_CHANGE_LOG_PKG" as
/*$Header: FIIFLOGB.pls 120.1 2005/10/30 05:14:11 appldev ship $*/

g_debug_flag  VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');


procedure update_change_log(p_log_item 		in varchar2,
                            p_item_value 	in varchar2,
			    x_status  		out nocopy varchar2,
                            x_message_count 	out nocopy number,
                            x_error_message 	out nocopy varchar2) is
begin
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_CHANGE_LOG_PKG.update_change_log(+)');
  end if;

  update fii_change_log
  set item_value = p_item_value,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.user_id
  where log_item = p_log_item;

  x_status := FND_API.G_RET_STS_SUCCESS;
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_CHANGE_LOG_PKG.update_change_log(-)');
  end if;

exception
  when others then
    x_status := FND_API.G_RET_STS_ERROR;
    x_message_count := 1;
    FND_MESSAGE.SET_NAME ('FII','FII_ERROR');
    FND_MESSAGE.SET_TOKEN('FUNCTION', 'FII_CHANGE_LOG_PKG.update_change_log');
    FND_MESSAGE.SET_TOKEN('SQLERRMC', sqlerrm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_message_count, p_data => x_error_message);
    if g_debug_flag = 'Y' then
      fii_util.debug_line('FII_CHANGE_LOG_PKG.update_change_log(EXCEPTION)');
      fii_util.debug_line(sqlerrm);
    end if;
end;


procedure set_recollection_for_fii(x_status 		out nocopy varchar2,
                                   x_message_count 	out nocopy number,
                                   x_error_message 	out nocopy varchar2) is
begin
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_CHANGE_LOG_PKG.set_recollection_for_fii(+)');
  end if;

  UPDATE FII_CHANGE_LOG
  SET item_value = 'Y',
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.user_id
  WHERE log_item IN
	('GL_RESUMMARIZE',
         'AP_RESUMMARIZE',
         'AR_RESUMMARIZE',
         'CCID_RELOAD',
		 'FA_RESUMMARIZE');

  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_CHANGE_LOG_PKG.set_recollection_for_fii(-)');
  end if;
  x_status := FND_API.G_RET_STS_SUCCESS;

exception
  when others then
    x_status := FND_API.G_RET_STS_ERROR;
    x_message_count := 1;
    FND_MESSAGE.SET_NAME ('FII','FII_ERROR');
    FND_MESSAGE.SET_TOKEN('FUNCTION', 'FII_CHANGE_LOG_PKG.set_recollection_for_fii');
    FND_MESSAGE.SET_TOKEN('SQLERRMC', sqlerrm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_message_count, p_data => x_error_message);
    if g_debug_flag = 'Y' then
      fii_util.debug_line('FII_CHANGE_LOG_PKG.set_recollection_for_fii(EXCEPTION)');
      fii_util.debug_line(sqlerrm);
    end if;

end;


procedure add_change_log_item(p_log_item 		in varchar2,
                              p_item_value 	    in varchar2,
			                  x_status  		out nocopy varchar2,
                              x_message_count 	out nocopy number,
                              x_error_message 	out nocopy varchar2) is
	l_item_count NUMBER(15);

begin
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_CHANGE_LOG_PKG.add_change_log_item(+)');
  end if;

   --Check if this item exists in fii_change_log table.
   --Add item only if it doesn't already exist.

   Select count(*) into l_item_count from fii_change_log where log_item = p_log_item;
   IF l_item_count = 0 THEN

	   INSERT INTO FII_CHANGE_LOG
		 (log_item,
	      item_value,
	 	  creation_date,
		  created_by,
	      last_update_date,
		  last_update_login,
		  last_updated_by)
		VALUES (p_log_item,
				p_item_value,
				sysdate,
		      	fnd_global.user_id,
	            sysdate,
		        fnd_global.login_Id,
		        fnd_global.user_id);

	END IF;

  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_CHANGE_LOG_PKG.add_change_log_item(-)');
  end if;
  x_status := FND_API.G_RET_STS_SUCCESS;

exception
  when others then
    x_status := FND_API.G_RET_STS_ERROR;
    x_message_count := 1;
    FND_MESSAGE.SET_NAME ('FII','FII_ERROR');
    FND_MESSAGE.SET_TOKEN('FUNCTION', 'FII_CHANGE_LOG_PKG.add_change_log_item');
    FND_MESSAGE.SET_TOKEN('SQLERRMC', sqlerrm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_message_count, p_data => x_error_message);
    if g_debug_flag = 'Y' then
      fii_util.debug_line('FII_CHANGE_LOG_PKG.add_change_log_item(EXCEPTION)');
      fii_util.debug_line(sqlerrm);
    end if;

end;

end FII_CHANGE_LOG_PKG;

/
