--------------------------------------------------------
--  DDL for Package Body BIS_FND_MENUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_FND_MENUS_PUB" as
/* $Header: BISPFMNB.pls 120.0 2005/05/31 18:23:34 appldev noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_FND_MENUS_PUB                                       --
--                                                                        --
--  DESCRIPTION:  Private package that calls the FND packages to          --
--		  insert records in the FND tables.          		      --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  03/05/04   nbarik     Initial creation                                --
--  07/19/04   ppalpart	  Create method DELETE_ROW_MENU_MENUENTRIES   	  --
--  03/01/05   mdamle     Added LOCK_ROW, X_MENU_ID In/Out parameter      --
--                        Added validation								  --
--  03/21/05   ankagarw   bug#4235732 - changing count(*) to count(1)     --
--  04/5/05    mdamle     Check for already deleted row in delete_row	  --
--  19-MAY-2005  visuri   GSCC Issues bug 4363854                         --
----------------------------------------------------------------------------

procedure INSERT_ROW (
 p_MENU_NAME 	in VARCHAR2
,p_USER_MENU_NAME 	in VARCHAR2
,p_TYPE 		in VARCHAR2 := NULL
,p_DESCRIPTION 		in VARCHAR2 := NULL
,x_MENU_ID 		in  OUT NOCOPY NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) is

l_rowid			VARCHAR2(30);
l_new_menu_id 		NUMBER;
l_menu_name		VARCHAR2(30);
l_user_menu_name	VARCHAR2(80);

begin

	fnd_msg_pub.initialize;

	begin
		select menu_name, user_menu_name
		into l_menu_name, l_user_menu_name
		from fnd_menus_vl
		where menu_name = p_menu_name
		or user_menu_name = p_user_menu_name;
	exception
		when others then null;
	end;

	if l_menu_name = p_menu_name then
		FND_MESSAGE.SET_NAME('BIS','BIS_NAME_UNIQUE_ERR');
 	        FND_MSG_PUB.ADD;
  	        RAISE FND_API.G_EXC_ERROR;
	end if;

	if l_user_menu_name = p_user_menu_name then
		FND_MESSAGE.SET_NAME('BIS','BIS_DISPLAY_NAME_UNIQUE_ERR');
 	        FND_MSG_PUB.ADD;
  	        RAISE FND_API.G_EXC_ERROR;
	end if;

	if X_MENU_ID IS NULL then
		select FND_MENUS_S.NEXTVAL into l_new_menu_id from dual;
	else
		l_new_menu_id := X_MENU_ID;
	end if;

	FND_MENUS_PKG.INSERT_ROW(
	       	X_ROWID                  => l_ROWID,
	       	X_MENU_ID                => l_new_menu_id,
	       	X_MENU_NAME              => upper(p_MENU_NAME),
	       	X_USER_MENU_NAME         => p_USER_MENU_NAME,
	       	X_MENU_TYPE              => p_TYPE,
	       	X_DESCRIPTION            => p_DESCRIPTION,
   		    X_CREATION_DATE 	     => sysdate,
		    X_CREATED_BY 		     => fnd_global.user_id,
		    X_LAST_UPDATE_DATE       => sysdate,
		    X_LAST_UPDATED_BY        => fnd_global.user_id,
		    X_LAST_UPDATE_LOGIN => fnd_global.user_id);

	if l_ROWID is not null then
		X_MENU_ID := l_new_menu_id;
	end if;

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
 p_MENU_ID 			in NUMBER
,p_USER_MENU_NAME 		in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_DESCRIPTION 			in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,x_return_status        	OUT NOCOPY VARCHAR2
,x_msg_count            	OUT NOCOPY NUMBER
,x_msg_data             	OUT NOCOPY VARCHAR2
) is

l_fnd_menu_rec Fnd_Menu_Rec_Type;

cursor cFndMenu is
select 	   menu_name,
	   type,
	   user_menu_name,
	   description
from fnd_menus_vl
where menu_id = p_MENU_ID;

l_count		NUMBER;
begin
        fnd_msg_pub.initialize;

	if cFndMenu%ISOPEN then
        	CLOSE cFndMenu;
	end if;

     	OPEN cFndMenu;
     	FETCH cFndMenu INTO
		l_fnd_menu_rec.menu_name,
		l_fnd_menu_rec.type,
		l_fnd_menu_rec.user_menu_name,
		l_fnd_menu_rec.description;
	CLOSE cFndMenu;

	if (p_user_menu_name <> BIS_COMMON_UTILS.G_DEF_CHAR) then
		l_fnd_menu_rec.user_menu_name := p_user_menu_name;

		select count(1)
		into l_count
		from fnd_menus_vl
		where menu_id <> p_menu_id
		and user_menu_name = p_user_menu_name;

		if l_count > 0 then
			FND_MESSAGE.SET_NAME('BIS','BIS_DISPLAY_NAME_UNIQUE_ERR');
 		    FND_MSG_PUB.ADD;
  	        	RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;

	if (p_description <> BIS_COMMON_UTILS.G_DEF_CHAR) then
		l_fnd_menu_rec.description := p_description;
	end if;

	FND_MENUS_PKG.UPDATE_ROW(
		X_MENU_ID => p_MENU_ID,
		X_MENU_NAME => l_fnd_menu_rec.menu_name,
		X_USER_MENU_NAME => l_fnd_menu_rec.user_menu_name,
		X_MENU_TYPE => l_fnd_menu_rec.type,
		X_DESCRIPTION => l_fnd_menu_rec.description,
		X_LAST_UPDATE_DATE => sysdate,
		X_LAST_UPDATED_BY => fnd_global.user_id,
		X_LAST_UPDATE_LOGIN => fnd_global.user_id
    );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  	if cFndMenu%ISOPEN then
        	CLOSE cFndMenu;
	end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  	if cFndMenu%ISOPEN then
        	CLOSE cFndMenu;
	end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
  	if cFndMenu%ISOPEN then
        	CLOSE cFndMenu;
	end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
  	if cFndMenu%ISOPEN then
        	CLOSE cFndMenu;
	end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;

end UPDATE_ROW;


PROCEDURE VALIDATE_DELETE (
 p_MENU_ID 			in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 ) IS

cursor cr_menu_usage is
select m.user_menu_name
from fnd_menus_vl m, fnd_menu_entries_vl me
where sub_menu_id = p_menu_id
and me.menu_id = m.menu_id;

cursor cr_resp_usage is
select responsibility_name
from fnd_responsibility_vl
where menu_id = p_menu_id;

BEGIN
	fnd_msg_pub.initialize;

	if cr_menu_usage%ISOPEN then
        	CLOSE cr_menu_usage;
	end if;
	if cr_resp_usage%ISOPEN then
        	CLOSE cr_resp_usage;
	end if;

        for c in cr_menu_usage loop
			FND_MESSAGE.SET_NAME('FND','MENU-USED BY MENUS');
			FND_MESSAGE.SET_TOKEN('MENU', c.user_menu_name);
 		    FND_MSG_PUB.ADD;
  	        	RAISE FND_API.G_EXC_ERROR;
	end loop;

        for c in cr_resp_usage loop
			FND_MESSAGE.SET_NAME('FND','FND-RESP CALLS MENU');
			FND_MESSAGE.SET_TOKEN('RESPONSIBILITY', c.responsibility_name);
 		    FND_MSG_PUB.ADD;
  	        	RAISE FND_API.G_EXC_ERROR;
	end loop;

	if cr_menu_usage%ISOPEN then
        	CLOSE cr_menu_usage;
	end if;
	if cr_resp_usage%ISOPEN then
        	CLOSE cr_resp_usage;
	end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    if cr_menu_usage%ISOPEN then
       	CLOSE cr_menu_usage;
    end if;
    if cr_resp_usage%ISOPEN then
       	CLOSE cr_resp_usage;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    if cr_menu_usage%ISOPEN then
       	CLOSE cr_menu_usage;
    end if;
    if cr_resp_usage%ISOPEN then
       	CLOSE cr_resp_usage;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    if cr_menu_usage%ISOPEN then
       	CLOSE cr_menu_usage;
    end if;
    if cr_resp_usage%ISOPEN then
       	CLOSE cr_resp_usage;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    if cr_menu_usage%ISOPEN then
       	CLOSE cr_menu_usage;
    end if;
    if cr_resp_usage%ISOPEN then
       	CLOSE cr_resp_usage;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;

END VALIDATE_DELETE;


PROCEDURE DELETE_ROW (
 p_MENU_ID 			in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 ) IS

l_menu_id number;
BEGIN
	fnd_msg_pub.initialize;

	validate_delete(p_menu_id, x_return_status, x_msg_count, x_msg_data);

	if (x_return_status is null) then
		begin
			select menu_id into l_menu_id from fnd_menus where menu_id = p_menu_id for update of menu_id nowait;
			FND_MENUS_PKG.DELETE_ROW(X_MENU_ID => p_MENU_ID);
		exception
			when others then
				    FND_MESSAGE.SET_NAME('BIS','BIS_MENU_DELETED_ERROR');
				    FND_MSG_PUB.ADD;
					RAISE FND_API.G_EXC_ERROR;
		end;
	end if;

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

END DELETE_ROW;

PROCEDURE DELETE_ROW_MENU_MENUENTRIES (
 p_MENU_ID 			in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 ) IS

l_return_status          VARCHAR2(40);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(40);
l_menu_id			 NUMBER;

BEGIN

   fnd_msg_pub.initialize;

   validate_delete(p_menu_id, x_return_status, x_msg_count, x_msg_data);

   if (x_return_status is null) then

	BIS_MENU_ENTRIES_PUB.DELETE_ROW (X_MENU_ID => p_MENU_ID,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data);

	begin
		FND_MENUS_PKG.DELETE_ROW(X_MENU_ID => p_MENU_ID);
   	exception
		when no_data_found then
		    FND_MESSAGE.SET_NAME('BIS','BIS_MENU_DELETED_ERROR');
		    FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
   	end;
    end if;

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

END DELETE_ROW_MENU_MENUENTRIES;

PROCEDURE LOCK_ROW
(  p_menu_id	                  IN         NUMBER
 , p_last_update_date		   	  IN		 DATE
) IS

 l_last_update_date	   date;

 cursor cMenu is
 select last_update_date
 from fnd_menus
 where menu_id = p_menu_id
 for update of menu_id nowait;

BEGIN

    fnd_msg_pub.initialize;

    SAVEPOINT SP_LOCK_ROW;

    IF cMenu%ISOPEN THEN
       CLOSE cMenu;
    END IF;
    OPEN cMenu;
    FETCH cMenu INTO l_last_update_date;

    if (cMenu%notfound) then
	FND_MESSAGE.SET_NAME('BIS','BIS_MENU_DELETED_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_last_update_date is not null then
	if p_last_update_date <> l_last_update_date then
		FND_MESSAGE.SET_NAME('BIS','BIS_MENU_CHANGED_ERROR');
 	        FND_MSG_PUB.ADD;
  	        RAISE FND_API.G_EXC_ERROR;
	end if;
    end if;

    rollback to SP_LOCK_ROW;
    CLOSE cMenu;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN NULL;
  WHEN OTHERS THEN
    close cMenu;
    rollback to SP_LOCK_ROW;
    FND_MESSAGE.SET_NAME('BIS','BIS_MENU_LOCKED_ERROR');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END LOCK_ROW;



END BIS_FND_MENUS_PUB;

/
