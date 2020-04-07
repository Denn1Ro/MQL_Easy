//+------------------------------------------------------------------+
//|                                                        Debug.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"

#ifdef __MQL4__
#property strict
#endif 



/*
   This is a custom data structure in order to use the printer class.
   If a key value structure needed for development it is better to use
   the CHashMap class which the metaquotes has implemented. 
*/
//+------------------------------------------------------------------+
//|                   CKeyValueStructure                             |
//+------------------------------------------------------------------+
class CKeyValueStructure
  {
private:
   string            Keys[];
   string            Values[];
   int               ResizeCapacity();
   
public:
                     CKeyValueStructure();
                    ~CKeyValueStructure();
   void              Add(string keyPar, string valuePar);
   void              Clear();
   string            GetKey(int indexPar);
   string            GetValue(int indexPar);
   string            GetValue(string keyPar);
   void              GetAllKeys(string &keysPar[]);
   void              GetAllValues(string &valuesPar[]);
                    
  };
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CKeyValueStructure::CKeyValueStructure()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CKeyValueStructure::~CKeyValueStructure()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|      add a key value pair
//+------------------------------------------------------------------+
void CKeyValueStructure::Add(string keyPar,string valuePar)
{
   int lastIndexTemp = this.ResizeCapacity();   
   this.Keys[lastIndexTemp]   = keyPar;
   this.Values[lastIndexTemp] = valuePar;
}

//+------------------------------------------------------------------+
//|     resize the capacity 
//+------------------------------------------------------------------+
int CKeyValueStructure::ResizeCapacity(void)
{
   int sizeTemp = ArraySize(this.Keys);
   sizeTemp    += 1;
   ArrayResize(this.Keys,sizeTemp);
   ArrayResize(this.Values,sizeTemp);
   return sizeTemp-1;
}

//+------------------------------------------------------------------+
//|      clear 
//+------------------------------------------------------------------+
void CKeyValueStructure::Clear(void)
{
   ArrayFree(this.Keys);
   ArrayFree(this.Values);
}

//+------------------------------------------------------------------+
//|     get key by index
//+------------------------------------------------------------------+
string CKeyValueStructure::GetKey(int indexPar)
{
   string keyTemp = "";
   if(indexPar >= ArraySize(this.Keys))return keyTemp;
   keyTemp        = this.Keys[indexPar]; 
   return keyTemp;  
}

//+------------------------------------------------------------------+
//|     get value by index  
//+------------------------------------------------------------------+
string CKeyValueStructure::GetValue(int indexPar)
{
   string valueTemp  = "";
   if(indexPar >= ArraySize(this.Values))return valueTemp;
   valueTemp         = this.Values[indexPar];
   return valueTemp;
}

//+------------------------------------------------------------------+
//|     get value by value
//+------------------------------------------------------------------+
string CKeyValueStructure::GetValue(string keyPar)
{
   string valueTemp  = "";
   for(int i = 0; i < ArraySize(Keys); i++){
      if(this.Keys[i] == keyPar)valueTemp = this.Values[i];
   }
   return valueTemp;
}

//+------------------------------------------------------------------+
//|     get all keys
//+------------------------------------------------------------------+
void CKeyValueStructure::GetAllKeys(string &keysPar[])
{
   int sizeTemp = ArraySize(this.Keys);
   ArrayResize(keysPar,sizeTemp);
   for(int i = 0; i < sizeTemp; i++){
      keysPar[i] = this.Keys[i];  
   }
}

//+------------------------------------------------------------------+
//|     get all values
//+------------------------------------------------------------------+
void CKeyValueStructure::GetAllValues(string &valuesPar[])
{
   int sizeTemp = ArraySize(this.Values);
   ArrayResize(valuesPar,sizeTemp);
   for(int i = 0; i < sizeTemp; i++){
      valuesPar[i] = this.Values[i];
   }
}





//+------------------------------------------------------------------+
//|                   CPrinter Class
//+------------------------------------------------------------------+
class CPrinter
  {
private:
   string               Title;
   string               Container;
   string               SeparatorKeyValue;
   CKeyValueStructure   KeyValue;

public:
                        CPrinter();
                       ~CPrinter();
                        template<typename T>
   void                 Add(string key, T item);
   void                 PrintContent();
   string               GetContent();
   void                 SetTitle(string titlePar="DEBUG"){this.Title = titlePar;}
   void                 SetContainer(string containerPar = "-",int numberPar = 15);
   void                 SetSeparatorKeyValue(string separatorKeyValuePar = " : "){this.SeparatorKeyValue = separatorKeyValuePar;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPrinter::CPrinter()
  {
   this.SetTitle();
   this.SetContainer();
   this.SetSeparatorKeyValue();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPrinter::~CPrinter()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|     set the container
//+------------------------------------------------------------------+
void CPrinter::SetContainer(string containerPar="-",int numberPar = 15)
{
   this.Container = " ";
   for(int i = 0; i < numberPar; i++){
      this.Container += containerPar;  
   }
   this.Container += " ";   
}


//+------------------------------------------------------------------+
//|     add a key value pair
//+------------------------------------------------------------------+
template<typename T>
void CPrinter::Add(string key, T item)
{
   this.KeyValue.Add(key,(string)item); 
}


//+------------------------------------------------------------------+
//|     print the content
//+------------------------------------------------------------------+
void CPrinter::PrintContent(void)
{
   Print(this.Container + this.Title + this.Container);
   string keys[];
   string values[];
   this.KeyValue.GetAllKeys(keys);
   this.KeyValue.GetAllValues(values);
   int size = ArraySize(keys);
   for(int i = 0; i < size; i++){
      Print(keys[i]+this.SeparatorKeyValue+values[i]);  
   }   
   Print(this.Container + this.Title + this.Container);
   this.KeyValue.Clear();
}

//+------------------------------------------------------------------+
//|     get the content
//+------------------------------------------------------------------+
string CPrinter::GetContent(void)
{
   string strTemp       = "";
   string keys[];
   string values[];
   this.KeyValue.GetAllKeys(keys);
   this.KeyValue.GetAllValues(values);
   int size = ArraySize(keys);
   for(int i = 0; i < size; i++){
      strTemp += keys[i]+this.SeparatorKeyValue+values[i];  
   }   
   return strTemp;
}







