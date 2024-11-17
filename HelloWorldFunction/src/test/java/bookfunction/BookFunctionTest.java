package bookfunction;

import bookfunction.controller.BookFunction;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import org.junit.Test;

import static org.junit.Assert.*;

public class BookFunctionTest
{
	@Test
	public void successfulResponseGetBooks()
	{
		BookFunction bookFunction = new BookFunction();
		APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
		request.setHttpMethod("GET");
		request.setPath("/book");

		final String pageContents = "189.68.4.22";

		APIGatewayProxyResponseEvent result = bookFunction.handleRequest(request, null);

		assertEquals(200, result.getStatusCode().intValue());
		assertEquals("application/json", result.getHeaders().get("Content-Type"));

		String content = result.getBody();
		assertNotNull(content);
		assertTrue(content.contains("message"));
		assertTrue(content.contains("Lista todos os livros"));
		assertTrue(content.contains("location"));
	}

	@Test
	public void successfulResponseGetBookById()
	{
		BookFunction bookFunction = new BookFunction();
		APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
		request.setHttpMethod("GET");
		request.setPath("/book/1");

		final String pageContents = "189.68.4.22";

		APIGatewayProxyResponseEvent result = bookFunction.handleRequest(request, null);

		assertEquals(200, result.getStatusCode().intValue());
		assertEquals("application/json", result.getHeaders().get("Content-Type"));

		String content = result.getBody();
		assertNotNull(content);
		assertTrue(content.contains("message"));
		assertTrue(content.contains("Busca livro por ID"));
		assertTrue(content.contains("location"));
	}
	@Test
	public void successfulResponsePostBook()
	{
		BookFunction bookFunction = new BookFunction();
		APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
		request.setHttpMethod("POST");
		request.setPath("/book");

		final String pageContents = "189.68.4.22";

		APIGatewayProxyResponseEvent result = bookFunction.handleRequest(request, null);

		assertEquals(201, result.getStatusCode().intValue());
		assertEquals("application/json", result.getHeaders().get("Content-Type"));

		String content = result.getBody();
		assertNotNull(content);
		assertTrue(content.contains("message"));
		assertTrue(content.contains("Cria Livro"));
		assertTrue(content.contains("location"));
	}

	@Test
	public void successfulResponseGetHello()
	{
		BookFunction bookFunction = new BookFunction();
		APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
		request.setHttpMethod("GET");
		request.setPath("/hello");

		final String pageContents = "189.68.4.22";

		APIGatewayProxyResponseEvent result = bookFunction.handleRequest(request, null);

		assertEquals(200, result.getStatusCode().intValue());
		assertEquals("application/json", result.getHeaders().get("Content-Type"));

		String content = result.getBody();
		assertNotNull(content);
		assertTrue(content.contains("message"));
		assertTrue(content.contains("Hello World"));
		assertTrue(content.contains("location"));
	}

	@Test
	public void failResponse()
	{
		BookFunction bookFunction = new BookFunction();
		APIGatewayProxyResponseEvent result = bookFunction.handleRequest(null, null);
		assertEquals(404, result.getStatusCode().intValue());
		assertEquals("application/json", result.getHeaders().get("Content-Type"));
		String content = result.getBody();
		assertNotNull(content);
		assertTrue(content.contains("message"));
		assertTrue(content.contains("ERRO!!!"));
		assertTrue(content.contains("location"));
	}
}
