--------------------------------------------------------
--  DDL for Package Body IGS_GE_MSG_STACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_MSG_STACK" AS
/* $Header: IGSGE09B.pls 115.4 2002/11/29 00:33:04 nsidana ship $ */

Procedure INITIALIZE as
Begin
FND_MSG_PUB.INITIALIZE;
End INITIALIZE;

FUNCTION COUNT_MSG
Return NUMBER as
BEGIN
return(FND_MSG_PUB.COUNT_MSG);
END COUNT_MSG;
PROCEDURE ADD as
lv_msg varchar2(2000);
ln_index number;
Begin
FND_MSG_PUB.ADD;
fnd_msg_pub.get(-3, 'T', lv_msg, ln_index);
fnd_message.set_encoded(lv_msg);
End ADD;

Procedure DELETE_MSG
(   p_msg_index IN    NUMBER	:=	NULL
) AS
BEGIN
FND_MSG_PUB.DELETE_MSG(p_msg_index);
End DELETE_MSG;

Procedure GET
(   p_msg_index	    IN	NUMBER,
    p_encoded	    IN	VARCHAR2,
    p_data	    OUT NOCOPY	VARCHAR2,
    p_msg_index_out OUT NOCOPY	NUMBER
) AS
BEGIN
FND_MSG_PUB.GET(p_msg_index, p_encoded, p_data, p_msg_index_out);
End GET;

Procedure CONC_EXCEPTION_HNDL
AS
lv_msg_text		VARCHAR2(2000);
ln_msg_index	NUMBER;
Begin
  If FND_PROFILE.VALUE('DEBUG_ON') <> 'Y' then
     While IGS_GE_MSG_STACK.COUNT_MSG <> 0 loop
	   IGS_GE_MSG_STACK.GET(-1, 'F', lv_msg_text, ln_msg_index);
	   FND_FILE.PUT_LINE(FND_FILE.LOG, lv_msg_text);
	   IGS_GE_MSG_STACK.DELETE_MSG(ln_msg_index);
	 END LOOP;
  else
     IGS_GE_MSG_STACK.GET(-1, 'F', lv_msg_text, ln_msg_index);
	 FND_FILE.PUT_LINE(FND_FILE.LOG, lv_msg_text);
  End If;
End CONC_EXCEPTION_HNDL;

End IGS_GE_MSG_STACK;

/
