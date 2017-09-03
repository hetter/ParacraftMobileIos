//-----------------------------------------------------------------------------
// Class:	CParaEngineCore
// Authors:	LiXizhi
// Emails:	LiXizhi@yeah.net
// Company: ParaEngine Tech Studio
// Date:	2006.8.4
// Desc: It implements the IParaEngineCore interface, which exposes everything in ParaEngine to plug-in applications. 
//-----------------------------------------------------------------------------
#include "ParaEngine.h"
#include "PluginAPI.h"
#include "ParaEngineApp.h"
#include "ParaEngineCore.h"

using namespace ParaEngine;

/** @def class id*/
#define PARAENGINE_CLASS_ID Class_ID(0x2b903b29, 0x47e409af)

/** description class */
class CParaEngineClassDesc : public ClassDescriptor 
{
public:

	void* Create(bool loading = FALSE) 
	{ 
		static CParaEngineCore g_singleton;
		return &g_singleton; 
	}

	const char* ClassName() 
	{ 
		return "ParaEngine"; 
	}

	SClass_ID SuperClassID() 
	{ 
		return OBJECT_MODIFIER_CLASS_ID; 
	}

	Class_ID ClassID() 
	{ 
		return PARAENGINE_CLASS_ID; 
	}

	const char* Category() 
	{ 
		return "ParaEngine"; 
	}

	const char* InternalName() 
	{ 
		return "ParaEngineCore"; 
	}	

	HINSTANCE HInstance() 
	{ 
		return NULL; 
	}
};

ClassDescriptor* ParaEngine::ParaEngine_GetClassDesc() 
{ 
	static CParaEngineClassDesc Desc;
	return &Desc; 
}


CParaEngineCore::CParaEngineCore(void)
{
}

CParaEngineCore::~CParaEngineCore(void)
{
}

IParaEngineCore* CParaEngineCore::GetStaticInterface()
{
	static CParaEngineCore g_instance;
	return (IParaEngineCore*)(&g_instance);
}

DWORD CParaEngineCore::GetVersion()
{
	return GetParaEngineVersion();
}

bool CParaEngineCore::Sleep(float fSeconds)
{
	SLEEP(static_cast<DWORD>(fSeconds*1000));
	return true;
}

IParaEngineApp* CParaEngineCore::GetAppInterface()
{
	return (IParaEngineApp*)(CParaEngineApp::GetInstance());
}

IParaEngineApp* CParaEngineCore::CreateApp()
{
	IParaEngineApp* pApp = GetAppInterface();
	if (pApp == 0)
	{
		// we will only create app if it has not been created before. 
		static CParaEngineApp g_app(NULL);
		return (IParaEngineApp*)(&g_app);
	}
	return pApp;
}
