--------------------------------------------------------
--  DDL for Package Body BIS_MENU_ENTRIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_MENU_ENTRIES_PUB" as
/* $Header: BISPMNEB.pls 120.3 2006/07/12 09:53:50 ankgoel noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_MENU_ENTRIES_PUB                                    --
--                                                                        --
--  DESCRIPTION:  Private package that calls the FND packages to          --
--		  insert records in the FND tables.          		      --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  11/21/01   mdamle     Initial creation                                --
--  12/25/03   mdamle     Added a generic routine to attach function to   --
--  			      menus   					  					  --
--  06/24/04   bewong	  Added a procedure to update the prompt of 	  --
-- 						  the function 							  --
--  07/14/04   ppalpart	  Added a procedures to delete roles     	      --
--  07/19/04   ppalpart	  Added a procedure to delete roles taking     	  --
--                        only Menu_Id                                    --
--  03/01/05   mdamle     Added UPDATE_ROW, LOCK_ROW                      --
--  03/21/05   ankagarw   bug#4235732 - changing count(*) to count(1)     --
--  11/03/05   rpenneru   bug#4698198 Added SUBMIT_COMPILE function to    --
--                        submit menu concurrent request                  --
--  26/06/06   hengliu    bug#5091570 Update menu row when menu entries   --
--                        have been changed                               --
--  12/07/06   ankgoel    Bug#5383908 Update menu row in UPDATE_ROW API   --
----------------------------------------------------------------------------

-- Defaults
X_WEB_SECURED			constant varchar2(1)	:= 'N';
X_WEB_ENCRYPT_PARAMETERS	constant varchar2(1)	:= 'N';

procedure INSERT_ROW (
	  X_ROWID in out NOCOPY VARCHAR2,
	  X_USER_ID in NUMBER,
	  X_MENU_ID in NUMBER,
	  X_FUNCTION_ID in NUMBER,
	  X_PROMPT in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2) is

l_new_entry_sequence 	NUMBER;
l_result			VARCHAR2(1);
l_return_status varchar2(1);
l_msg_count number;
l_msg_data  varchar2(200);

begin

	begin
		select nvl(max(entry_sequence), 0) + 1
  		into l_new_entry_sequence
	  	from fnd_menu_entries
  		where menu_id = X_MENU_ID;
	exception
		when no_data_found then l_new_entry_sequence :=1;
	end;

	FND_MENU_ENTRIES_PKG.INSERT_ROW(
		X_ROWID => X_ROWID,
	  	X_MENU_ID => X_MENU_ID,
	  	X_ENTRY_SEQUENCE => l_new_entry_sequence,
	  	X_SUB_MENU_ID => null,
	  	X_FUNCTION_ID => X_FUNCTION_ID ,
	  	X_GRANT_FLAG => null,
	  	X_PROMPT => X_PROMPT,
	  	X_DESCRIPTION => X_DESCRIPTION,
		X_CREATION_DATE => sysdate,
		X_CREATED_BY => X_USER_ID,
		X_LAST_UPDATE_DATE => sysdate,
		X_LAST_UPDATED_BY => X_USER_ID,
		X_LAST_UPDATE_LOGIN => X_USER_ID);

	BIS_FND_MENUS_PUB.UPDATE_ROW(
		P_MENU_ID => X_MENU_ID,
		X_RETURN_STATUS => l_return_status,
		X_MSG_COUNT => l_msg_count,
		X_MSG_DATA => l_msg_data);

	l_result := BIS_MENU_ENTRIES_PUB.SUBMIT_COMPILE;

end INSERT_ROW;

procedure INSERT_ROW (
	  X_MENU_ID 			in NUMBER,
	  X_ENTRY_SEQUENCE 		in NUMBER,
	  X_SUB_MENU_ID 		in NUMBER,
	  X_FUNCTION_ID 		in NUMBER,
	  X_GRANT_FLAG			in VARCHAR2,
	  X_PROMPT 				in VARCHAR2,
	  X_DESCRIPTION			in VARCHAR2,
	  x_return_status       OUT NOCOPY VARCHAR2,
          x_msg_count           OUT NOCOPY NUMBER,
          x_msg_data            OUT NOCOPY VARCHAR2) is

l_rowid 			varchar2(240);
l_result			VARCHAR2(1);
begin

	fnd_msg_pub.initialize;

	FND_MENU_ENTRIES_PKG.INSERT_ROW(
		X_ROWID => l_ROWID,
	  	X_MENU_ID => X_MENU_ID,
	  	X_ENTRY_SEQUENCE => X_ENTRY_SEQUENCE,
	  	X_SUB_MENU_ID => X_SUB_MENU_ID,
	  	X_FUNCTION_ID => X_FUNCTION_ID ,
	  	X_GRANT_FLAG => X_GRANT_FLAG,
	  	X_PROMPT => X_PROMPT,
	  	X_DESCRIPTION => X_DESCRIPTION,
		X_CREATION_DATE => sysdate,
		X_CREATED_BY => fnd_global.user_id,
		X_LAST_UPDATE_DATE => sysdate,
		X_LAST_UPDATED_BY => fnd_global.user_id,
		X_LAST_UPDATE_LOGIN => fnd_global.user_id);

	BIS_FND_MENUS_PUB.UPDATE_ROW(
		P_MENU_ID => X_MENU_ID,
		X_RETURN_STATUS => X_RETURN_STATUS,
		X_MSG_COUNT => X_MSG_COUNT,
		X_MSG_DATA => X_MSG_DATA);

	l_result := BIS_MENU_ENTRIES_PUB.SUBMIT_COMPILE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;

end INSERT_ROW;

procedure UPDATE_ROW (
	  X_MENU_ID 			in NUMBER,
	  X_ENTRY_SEQUENCE 		in NUMBER,
	  X_SUB_MENU_ID 		in NUMBER,
	  X_FUNCTION_ID 		in NUMBER,
	  X_GRANT_FLAG			in VARCHAR2,
	  X_PROMPT 				in VARCHAR2,
	  X_DESCRIPTION			in VARCHAR2,
	  x_return_status       OUT NOCOPY VARCHAR2,
          x_msg_count           OUT NOCOPY NUMBER,
          x_msg_data            OUT NOCOPY VARCHAR2) is

l_result			VARCHAR2(1);
begin

	fnd_msg_pub.initialize;

	FND_MENU_ENTRIES_PKG.UPDATE_ROW(
	  	X_MENU_ID => X_MENU_ID,
	  	X_ENTRY_SEQUENCE => X_ENTRY_SEQUENCE,
	  	X_SUB_MENU_ID => X_SUB_MENU_ID,
	  	X_FUNCTION_ID => X_FUNCTION_ID ,
	  	X_GRANT_FLAG => X_GRANT_FLAG,
	  	X_PROMPT => X_PROMPT,
	  	X_DESCRIPTION => X_DESCRIPTION,
		X_LAST_UPDATE_DATE => sysdate,
		X_LAST_UPDATED_BY => fnd_global.user_id,
		X_LAST_UPDATE_LOGIN => fnd_global.user_id);

	BIS_FND_MENUS_PUB.UPDATE_ROW(
		P_MENU_ID => X_MENU_ID,
		X_RETURN_STATUS => X_RETURN_STATUS,
		X_MSG_COUNT => X_MSG_COUNT,
		X_MSG_DATA => X_MSG_DATA);

	l_result := BIS_MENU_ENTRIES_PUB.SUBMIT_COMPILE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;

end UPDATE_ROW;


procedure UPDATE_PROMPT (
	  X_USER_ID in NUMBER,
	  X_MENU_ID in NUMBER,
	  X_OLD_ENTRY_SEQUENCE in NUMBER,
	  X_FUNCTION_ID in NUMBER,
	  X_PROMPT in VARCHAR2) is

  l_des fnd_menu_entries_vl.description%TYPE;
  CURSOR c1 is
  	SELECT description
  	FROM fnd_menu_entries_vl f
  	WHERE f.menu_id = X_MENU_ID
  	AND f.entry_sequence = X_OLD_ENTRY_SEQUENCE;

begin
	-- get description from query
    OPEN c1;
    FETCH c1 INTO l_des;
    CLOSE c1;

	FND_MENU_ENTRIES_PKG.UPDATE_ROW(
	  	X_MENU_ID => X_MENU_ID,
	  	X_ENTRY_SEQUENCE => X_OLD_ENTRY_SEQUENCE,
	  	X_SUB_MENU_ID => null,
	  	X_FUNCTION_ID => X_FUNCTION_ID ,
	  	X_GRANT_FLAG => null,
	  	X_PROMPT => X_PROMPT,
	  	X_DESCRIPTION => l_des,
		X_LAST_UPDATE_DATE => sysdate,
		X_LAST_UPDATED_BY => X_USER_ID,
		X_LAST_UPDATE_LOGIN => X_USER_ID);

end UPDATE_PROMPT;

procedure DELETE_ROW (
	  X_MENU_ID              in         NUMBER,
	  X_ENTRY_SEQUENCE       in         NUMBER,
	  x_return_status        OUT NOCOPY VARCHAR2,
          x_msg_count            OUT NOCOPY NUMBER,
          x_msg_data             OUT NOCOPY VARCHAR2) is

l_result			VARCHAR2(1);
begin

fnd_msg_pub.initialize;

	FND_MENU_ENTRIES_PKG.DELETE_ROW(
		X_MENU_ID => X_MENU_ID,
	  	X_ENTRY_SEQUENCE => X_ENTRY_SEQUENCE);

	BIS_FND_MENUS_PUB.UPDATE_ROW(
		P_MENU_ID => X_MENU_ID,
		X_RETURN_STATUS => X_RETURN_STATUS,
		X_MSG_COUNT => X_MSG_COUNT,
		X_MSG_DATA => X_MSG_DATA);

	l_result := BIS_MENU_ENTRIES_PUB.SUBMIT_COMPILE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
end DELETE_ROW;

procedure DELETE_ROW (
	  X_MENU_ID              in         NUMBER,
	  x_return_status        OUT NOCOPY VARCHAR2,
          x_msg_count            OUT NOCOPY NUMBER,
          x_msg_data             OUT NOCOPY VARCHAR2) is

cursor entry_sequence_cursor is
                           select entry_sequence
                           from fnd_menu_entries
                           where menu_id = X_MENU_ID;
l_result			VARCHAR2(1);
begin

  fnd_msg_pub.initialize;

  for entry_seq_cursor in entry_sequence_cursor loop

	FND_MENU_ENTRIES_PKG.DELETE_ROW(
		X_MENU_ID => X_MENU_ID,
	  	X_ENTRY_SEQUENCE => entry_seq_cursor.entry_sequence);
  end loop;

  BIS_FND_MENUS_PUB.UPDATE_ROW(
  	P_MENU_ID => X_MENU_ID,
  	X_RETURN_STATUS => X_RETURN_STATUS,
  	X_MSG_COUNT => X_MSG_COUNT,
	X_MSG_DATA => X_MSG_DATA);

  l_result := BIS_MENU_ENTRIES_PUB.SUBMIT_COMPILE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
end DELETE_ROW;


procedure AttachFunctionToMenus(
p_function_id           IN NUMBER
,p_menu_ids    		IN FND_TABLE_OF_NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) is

l_count		NUMBER;
l_prompt 	VARCHAR2(80);
l_row_id		VARCHAR2(30);
begin

    fnd_msg_pub.initialize;

    for i in 1..p_menu_ids.count loop
	-- Check if menu attachment already exists, then leave it alone
	select count(1) into l_count
	from fnd_menu_entries
	where function_id = p_function_id
	and menu_id = p_menu_ids(i);

	if (l_count = 0) then
		-- Attach the menu

		select user_function_name into l_prompt
		from fnd_form_functions_vl
		where function_id = p_function_id;

		INSERT_ROW (
	  		X_ROWID => l_row_id,
			X_USER_ID => fnd_global.user_id,
	  		X_MENU_ID => p_menu_ids(i),
	  		X_FUNCTION_ID => p_function_id,
	  		X_PROMPT => l_prompt,
	  		X_DESCRIPTION => l_prompt);
	end if;

    end loop;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
end AttachFunctionToMenus;


procedure AttachFunctionsToMenu(
 p_menu_id           IN NUMBER
,p_function_ids    		IN FND_TABLE_OF_NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) is

l_count		NUMBER;
l_prompt 	VARCHAR2(80);
l_row_id		VARCHAR2(30);
begin

    fnd_msg_pub.initialize;

    for i in 1..p_function_ids.count loop
	-- Check if function is added to the menu, then leave it alone
	select count(1) into l_count
	from fnd_menu_entries
	where function_id = p_function_ids(i)
	and menu_id = p_menu_id;

	if (l_count = 0) then
		-- Attach the function

		select user_function_name into l_prompt
		from fnd_form_functions_vl
		where function_id = p_function_ids(i);

		INSERT_ROW (
	  		X_ROWID => l_row_id,
			X_USER_ID => fnd_global.user_id,
	  		X_MENU_ID => p_menu_id,
	  		X_FUNCTION_ID => p_function_ids(i),
	  		X_PROMPT => l_prompt,
	  		X_DESCRIPTION => l_prompt);
	end if;

    end loop;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
end AttachFunctionsToMenu;

procedure DeleteFunctionsFromMenu(
 p_menu_id           IN NUMBER
,p_function_ids      IN FND_TABLE_OF_NUMBER
,x_return_status     OUT NOCOPY VARCHAR2
,x_msg_count         OUT NOCOPY NUMBER
,x_msg_data          OUT NOCOPY VARCHAR2
)

is

cursor entry_seq_cursor(p_function_id NUMBER) is
                                                  select entry_sequence
                                                  from fnd_menu_entries
                                                  where function_id = p_function_id
                                                  and menu_id = p_menu_id;

p_return_status        VARCHAR2(40);
p_msg_count            NUMBER;
p_msg_data             VARCHAR2(40);

begin

    fnd_msg_pub.initialize;

 for i in 1..p_function_ids.count loop

      for ent_seq_cur in entry_seq_cursor(p_function_ids(i)) loop

           DELETE_ROW (X_MENU_ID => p_menu_id,
                       X_ENTRY_SEQUENCE => ent_seq_cur.entry_sequence,
                       x_return_status => p_return_status,
                       x_msg_count => p_msg_count,
                       x_msg_data => p_msg_data);

      end loop;

 end loop;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
end DeleteFunctionsFromMenu;

procedure DeleteFunctionFromMenus(
p_function_id           IN NUMBER
,p_menu_ids    		IN FND_TABLE_OF_NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) is

cursor entry_seq_cursor(p_menu_id NUMBER) is
                                                  select entry_sequence
                                                  from fnd_menu_entries
                                                  where function_id = p_function_id
                                                  and menu_id = p_menu_id;

p_return_status        VARCHAR2(40);
p_msg_count            NUMBER;
p_msg_data             VARCHAR2(40);

begin

    fnd_msg_pub.initialize;

 for i in 1..p_menu_ids.count loop

      for ent_seq_cur in entry_seq_cursor(p_menu_ids(i)) loop

           DELETE_ROW (X_MENU_ID => p_menu_ids(i),
                       X_ENTRY_SEQUENCE => ent_seq_cur.entry_sequence,
                       x_return_status => p_return_status,
		       x_msg_count => p_msg_count,
                       x_msg_data => p_msg_data);

      end loop;

 end loop;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
end DeleteFunctionFromMenus;


PROCEDURE LOCK_ROW
(  p_menu_id	                  IN         NUMBER
 , p_entry_sequence			      IN 		 NUMBER
 , p_last_update_date		   	  IN		 DATE
) IS

 l_last_update_date	   date;

 cursor cMenuEntry is
 select last_update_date
 from fnd_menu_entries
 where menu_id = p_menu_id
 and entry_sequence = p_entry_sequence
 for update of menu_id, entry_sequence nowait;

BEGIN

    fnd_msg_pub.initialize;

    SAVEPOINT SP_LOCK_ROW;

    IF cMenuEntry%ISOPEN THEN
       CLOSE cMenuEntry;
    END IF;
    OPEN cMenuEntry;
    FETCH cMenuEntry INTO l_last_update_date;

    if (cMenuEntry%notfound) then
	FND_MESSAGE.SET_NAME('BIS','BIS_MENU_ENTRY_DELETED_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_last_update_date is not null then
	if p_last_update_date <> l_last_update_date then
		FND_MESSAGE.SET_NAME('BIS','BIS_MENU_ENTRY_CHANGED_ERROR');
 	        FND_MSG_PUB.ADD;
  	        RAISE FND_API.G_EXC_ERROR;
	end if;
    end if;

    rollback to SP_LOCK_ROW;
    CLOSE cMenuEntry;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN NULL;
  WHEN OTHERS THEN
    close cMenuEntry;
    rollback to SP_LOCK_ROW;
    FND_MESSAGE.SET_NAME('BIS','BIS_MENU_ENTRY_LOCKED_ERROR');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END LOCK_ROW;


/*
 * Function used to submit the concurrent request to compile
 * Menus after delete, insert or update
 *
 * This function will store the application context and
 * restore back once the request is submitted.
 */

FUNCTION submit_compile RETURN VARCHAR2
IS
  l_result VARCHAR2(1);
  l_userId NUMBER;
  l_respId NUMBER;
  l_respAppId NUMBER;
BEGIN

  /* Store the FND_GLOBAL user_id, resp_id and appl_id. to
     restore back after SUBMIT_COMPILE */

  l_userId := FND_GLOBAL.USER_ID;
  l_respId := FND_GLOBAL.RESP_ID;
  l_respAppId := FND_GLOBAL.RESP_APPL_ID;

  l_result := FND_MENU_ENTRIES_PKG.SUBMIT_COMPILE;

  /** restore the application context back */

  FND_GLOBAL.APPS_INITIALIZE(l_userId,l_respId,l_respAppId);

  RETURN(l_result);
END submit_compile;


END BIS_MENU_ENTRIES_PUB;

/
