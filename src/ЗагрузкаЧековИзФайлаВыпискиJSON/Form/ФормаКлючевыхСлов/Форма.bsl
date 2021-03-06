﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("СтатьяРасхода", СтатьяРасхода);
	Параметры.Свойство("КомментарийСтроки", КомментарийСтроки);
	
	Заголовок = СтрШаблон(НСтр("ru = 'Статья расходов ""%1"": ключевые слова'"), СтатьяРасхода);
	
	ИдентификаторОбъектаСтатьяРасхода = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Справочник.СтатьиРасходов");
	
	лМассивСтрок = СтрРазделить(КомментарийСтроки, " ", Ложь);
	
	лКлючевыеСлова = Новый Массив;
	Для Каждого стр Из лМассивСтрок Цикл
		Если СтрДлина(стр) < 3 Тогда
			Продолжить;
		КонецЕсли;
		лСлово = НРег(стр);
		Если НЕ лКлючевыеСлова.Найти(лСлово) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		лКлючевыеСлова.Добавить(лСлово);
		КлючевыеСлова.Добавить().КлючевоеСлово = лСлово;
	КонецЦикла;
	
	Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	КлючевыеСловаОбъектов.КлючевоеСлово КАК КлючевоеСлово
		|ИЗ
		|	РегистрСведений.КлючевыеСловаОбъектов КАК КлючевыеСловаОбъектов
		|ГДЕ
		|	КлючевыеСловаОбъектов.ИдентификаторОбъекта = &ИдентификаторОбъекта
		|	И КлючевыеСловаОбъектов.Объект = &Объект
		|
		|УПОРЯДОЧИТЬ ПО
		|	КлючевоеСлово"
	);
	Запрос.УстановитьПараметр("ИдентификаторОбъекта", ИдентификаторОбъектаСтатьяРасхода);
	Запрос.УстановитьПараметр("Объект", СтатьяРасхода);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		лОтбор = Новый Структура("КлючевоеСлово", Выборка.КлючевоеСлово);
		лНайденныеСтроки = КлючевыеСлова.НайтиСтроки(лОтбор);
		Если ЗначениеЗаполнено(лНайденныеСтроки) Тогда
			лНайденныеСтроки[0].Пометка = Истина;
			Продолжить;
		КонецЕсли;
		лНоваяСтрока = КлючевыеСлова.Добавить();
		лНоваяСтрока.КлючевоеСлово = Выборка.КлючевоеСлово;
		лНоваяСтрока.Пометка = Истина;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыКлючевыеСлова

&НаКлиенте
Процедура КлючевыеСловаПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Если Копирование Тогда
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КлючевыеСловаПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	Если НоваяСтрока Тогда
		Элемент.ТекущиеДанные.Пометка = Истина;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	ЗаписатьКлючевыеСловаНаСервере();
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаписатьКлючевыеСловаНаСервере()
	
	лНаборЗаписей = РегистрыСведений.КлючевыеСловаОбъектов.СоздатьНаборЗаписей();
	лНаборЗаписей.Отбор.ИдентификаторОбъекта.Установить(ИдентификаторОбъектаСтатьяРасхода);
	лНаборЗаписей.Отбор.Объект.Установить(СтатьяРасхода);
	
	лДобаленныеСлова = Новый Массив;
	
	лКлючевыеСлова = КлючевыеСлова.Выгрузить(Новый Структура("Пометка", Истина), "КлючевоеСлово").ВыгрузитьКолонку("КлючевоеСлово");
	Для Каждого стр Из лКлючевыеСлова Цикл
		лСлово = СокрЛП(стр);
		лСлово = НРег(лСлово);
		Если СтрДлина(лСлово) < 3 ИЛИ НЕ лДобаленныеСлова.Найти(лСлово) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		лДобаленныеСлова.Добавить(лСлово);
	    лЗаписьРегистра = лНаборЗаписей.Добавить();
		лЗаписьРегистра.КлючевоеСлово           = лСлово;
		лЗаписьРегистра.ИдентификаторОбъекта    = ИдентификаторОбъектаСтатьяРасхода;
		лЗаписьРегистра.Объект                  = СтатьяРасхода;
	КонецЦикла;
	
	лНаборЗаписей.Записать();
	
КонецПроцедуры

#КонецОбласти