
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;
Перем ИспользуемаяВерсияПлатформы;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Обновляет хранилище конфигурации из указанного cf-файла");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-params",
		"Файлы JSON содержащие значения параметров,
		|могут быть указаны несколько файлов разделенные "";""
		|(параметры командной строки имеют более высокий приоритет)");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-ib-path",
		"Адрес ИБ для выполнения обновления (если не указан, то будет создана временная база)");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-ib-user",
		"Пользователь ИБ для обновления (если указано -upddb-path)");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-ib-pwd",
		"Пароль пользователя ИБ для обновления (если указано -upddb-path)");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-path",
		"Адрес хранилища конфигурации");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-user",
		"Пользователь хранилища конфигурации");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-pwd",
		"Пароль пользователя хранилища конфигурации");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-upd-db",
		"Обновить конфигурацию ИБ");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-uccode",
		"Ключ разрешения запуска обновляемой ИБ");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-v8version",
		"Версия платформы 1С");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	ЗапускПриложений.ПрочитатьПараметрыКомандыИзФайла(ПараметрыКоманды["-params"], ПараметрыКоманды);
	
	ИБ_Адрес						= ПараметрыКоманды["-ib-path"];
	ИБ_ИмяПользователя				= ПараметрыКоманды["-ib-user"];
	ИБ_ПарольПользователя			= ПараметрыКоманды["-ib-pwd"];
	Хранилище_Адрес					= ПараметрыКоманды["-storage-path"];
	Хранилище_Пользователь			= ПараметрыКоманды["-storage-user"];
	Хранилище_ПарольПользователя	= ПараметрыКоманды["-storage-pwd"];
	ОбновитьКонфигурациюБД			= ПараметрыКоманды["-upd-db"];
	КлючРазрешения					= ПараметрыКоманды["-uccode"];
	ИспользуемаяВерсияПлатформы		= ПараметрыКоманды["-v8version"];
	
	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();

	Если ПустаяСтрока(ИБ_Адрес) Тогда
		Лог.Ошибка("Не указан адрес обновляемой ИБ");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(Хранилище_Адрес) Тогда
		Лог.Ошибка("Не указан адрес хранилища конфигурации");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(Хранилище_Пользователь) Тогда
		Лог.Ошибка("Не указан пользователь хранилища конфигурации");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Лог.Информация("Начало обновления ИБ из хранилища");

	Попытка
		ОбновитьКонфигурациюИзХранилища(ИБ_Адрес
									  , ИБ_ИмяПользователя
									  , ИБ_ПарольПользователя
									  , Хранилище_Адрес
									  , Хранилище_Пользователь
									  , Хранилище_ПарольПользователя
									  , ОбновитьКонфигурациюБД
									  , КлючРазрешения
									  , ИспользуемаяВерсияПлатформы);

		Возврат ВозможныйРезультат.Успех;
	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

КонецФункции

// Обновляет конфигурацию ИБ из указанного хранилища
//   
// Параметры:
//   ИБ_Адрес						- Строка - Строка подключения к обновляемой ИБ
//   ИБ_ИмяПользователя			 	- Строка - Пользователь обновляемой ИБ
//   ИБ_ПарольПользователя		 	- Строка - Пароль пользователя обновляемой ИБ
//   Хранилище_Адрес				- Строка - Адрес хранилища конфигурации
//   Хранилище_ИмяПользователя	 	- Строка - Пользователь хранилища конфигурации
//   Хранилище_ПарольПользователя 	- Строка - Пароль пользователя хранилища конфигурации
//   ОбновитьКонфигурациюБД	 		- Булево - Истина - будет выполнено обновление конфигурации ИБ,
//											   Ложь - будет обновлена только основная конфигурация
//   КлючРазрешения			 		- Строка - Ключ разрешения запуска обновляемой ИБ
//	 ИспользуемаяВерсияПлатформы	- Строка - Используемая версия платформы
//
Процедура ОбновитьКонфигурациюИзХранилища(ИБ_Адрес = ""
										, ИБ_ИмяПользователя = ""
										, ИБ_ПарольПользователя= ""
										, Хранилище_Адрес
										, Хранилище_ИмяПользователя
										, Хранилище_ПарольПользователя = ""
										, ОбновитьКонфигурациюБД = Ложь
										, КлючРазрешения = ""
										, ИспользуемаяВерсияПлатформы)
	
	Конфигуратор = ЗапускПриложений.НастроитьКонфигуратор(
														, ИБ_Адрес
														, ИБ_ИмяПользователя
														, ИБ_ПарольПользователя
														, ИспользуемаяВерсияПлатформы);
	
	Если Не ПустаяСтрока(КлючРазрешения) Тогда
		Конфигуратор.УстановитьКлючРазрешенияЗапуска(КлючРазрешения);
	КонецЕсли;

	Конфигуратор.ПолучитьИзмененияКонфигурацииБазыДанныхИзХранилища(Хранилище_Адрес, Хранилище_ИмяПользователя, Хранилище_ПарольПользователя);
	Лог.Информация("Основная конфигурация обновлена из хранилища");
	
	Если ОбновитьКонфигурациюБД Тогда
		Конфигуратор.ОбновитьКонфигурациюБазыДанныхИзХранилища(Хранилище_Адрес, Хранилище_ИмяПользователя, Хранилище_ПарольПользователя);
		Лог.Информация("Обновлена конфигурация ИБ");
	КонецЕсли;
	
КонецПроцедуры //ОбновитьКонфигурациюИзХранилища()

Лог = Логирование.ПолучитьЛог("ktb.app.yadt");